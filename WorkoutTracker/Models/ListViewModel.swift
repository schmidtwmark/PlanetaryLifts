//
//  ListViewModel.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/20/24.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ListViewModel {
    struct ListViewData {
        var lifts: [Lift]
        var liftsByDate: [(TimelessDate, [Lift])]
        var presentTypes: Set<LiftType>
        var presentTypesByCategory: [LiftCategory: [LiftType]]
    }
    
    enum State {
        case loading
        case loaded(ListViewData)
        case error
    }
    
    
    var modelContext: ModelContext
    var state: State
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.state = .loading
    }
    
    func load() {
        do {
            
            let typesDescriptor = FetchDescriptor<UserGeneratedLiftType>()
            let userGeneratedTypes = try modelContext.fetch(typesDescriptor)
            
            let liftsDescriptor = FetchDescriptor<Lift>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            let lifts = try modelContext.fetch(liftsDescriptor)
            
            let presentTypes = Set(lifts.map({$0.type}))
            
            let presentTypesByCategory = generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes).mapValues({ liftTypes in
                liftTypes.filter({ liftType in
                    presentTypes.contains(liftType)
                })
            }).filter({!$0.value.isEmpty})
            
            let liftsByDate = lifts.reduce(into: [(TimelessDate, [Lift])](), { result, lift in
                let currentDate = lift.date
                if let lastDate = result.last, lastDate.0 == currentDate {
                    result[result.endIndex - 1].1.append(lift)
                } else {
                    result.append((currentDate, [lift]))
                }
            })
            
            self.state = .loaded(.init(lifts: lifts, liftsByDate: liftsByDate, presentTypes: presentTypes, presentTypesByCategory: presentTypesByCategory))
            
        } catch {
            print("Fetch failed ")
            self.state = .error
        }
    }
    
    var loadedData: ListViewData? {
        if case .loaded(let data) = state {
            return data
        } else {
            return nil
        }
    }
    
    func getMostRecentLiftType() -> LiftType? {
        return loadedData?.lifts.first?.type
    }
}
