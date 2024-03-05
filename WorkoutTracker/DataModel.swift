//
//  DataModel.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import Foundation
import SwiftData

@Model
final class Lift {
    var type: LiftType
    
    var sets: [LiftSet]
    
    var timestamp: Date
    var equalWeight: Bool = true
    var equalReps: Bool = true
    var weighted: Bool = true
    var notes: String = ""
    
    init(liftType: LiftType, sets: [LiftSet] = [], timestamp: Date) {
        self.type = liftType
        self.sets = sets
        self.timestamp = timestamp
    }
    
    func addSet(_ reps: Int, weight: Weight) {
        let set = LiftSet(reps: reps, weight: weight)
        sets.append(set)
    }
    
    func allSetsSame() -> Bool {
        if let first = sets.first {
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight.weight == first.weight.weight && $0.weight.units == first.weight.units})
        } else {
            return false
        }
    }
}

final class LiftSet : Codable, Identifiable {
    var reps: Int
    var weight: Weight
    var id: UUID = UUID()
    
    init(reps: Int, weight: Weight) {
        self.reps = reps
        self.weight = weight
    }
}

final class Weight : Codable {
    var weight: Double
    var units: WeightUnits
    
    init(weight: Double, units: WeightUnits) {
        self.weight = weight
        self.units = units
    }
    
    func convert(to: WeightUnits) -> Weight{
        return switch (units, to) {
        case (.pounds, .kilograms): Weight(weight: 0.453592 * weight, units: .kilograms)
        case (.kilograms, .pounds): Weight(weight: 2.20462 * weight, units: .pounds)
        default: self
        }
    }
    
    var string: String {
        weight == 1.0 ? "**1** \(units.singleUnit)" : "**\(weight.clean)** \(units.singleUnit)s"
    }
}

@Model
final class UserGeneratedLiftType  {
    var name: String
    var category: LiftCategory
    var id: UUID = UUID()
    
    init(name: String, category: LiftCategory) {
        self.name = name
        self.category = category
    }
}
