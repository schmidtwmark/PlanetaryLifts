//
//  SwiftUIView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    @Environment(\.modelContext) private var modelContext
    @State var searchText = ""
    
    var liftsByType: [LiftType: [Lift]] {
        return Dictionary(grouping: lifts, by: { lift in
            lift.type
        })
    }
    
    var allLiftsByCategory: [LiftCategory: [LiftType]] {
        generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes)
    }
    
    var filteredCategories : [LiftCategory] {
        allLiftsByCategory.keys.filter({ category in
            // there are liftTypes in this category
            !allLiftsByCategory[category]!.isEmpty &&
            // passes search
            (searchText == "" ||
            category.rawValue.containsIgnoringCase(searchText) ||
            allLiftsByCategory[category]!.contains(where: { liftType in
                liftType.string.containsIgnoringCase(searchText)
            })) &&
            // there are lifts for some lifttype in this category
            (
                allLiftsByCategory[category]!.contains(where: { liftType in liftsByType.keys.contains(where: {$0 == liftType})
                })
            )
        })
    }

    var body: some View {
        
        NavigationStack {
            List {
                ForEach(filteredCategories, id: \.rawValue) { category in
                    Section(category.rawValue) {
                        ForEach(allLiftsByCategory[category]!, id: \.string) { liftType in
                            if let lifts = liftsByType[liftType] {
                                NavigationLink(destination: {
                                    StatItem(type: liftType, lifts: lifts)

                                }, label: {
                                    Text("\(liftType.string)")
                                })
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Stats")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for days in 0...50 {
        let lift = Lift(liftType: .benchPress, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
        container.mainContext.insert(lift)
        
        lift.addSet(5, weight: Double.random(in: 150...250), units: .pounds)
        lift.addSet(10, weight: Double.random(in: 100...200), units: .pounds)
    }
    
    return StatsView().modelContainer(container)
}
