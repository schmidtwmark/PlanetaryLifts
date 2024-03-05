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
    
    func addSet(_ reps: Int, weight: Double, units: WeightUnits) {
        let set = LiftSet(reps: reps, weight: weight, units: units)
        sets.append(set)
    }
    
    func allSetsSame() -> Bool {
        if let first = sets.first {
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight == first.weight && $0.units == first.units})
        } else {
            return false
        }
    }
}

final class LiftSet : Codable, Identifiable {
    var reps: Int
    var weight: Double
    var units: WeightUnits
    
    var id: UUID = UUID()
    
    init(reps: Int, weight: Double, units: WeightUnits) {
        self.reps = reps
        self.weight = weight
        self.units = units
    }
    
    var roundedWeight : Double {
        round(weight / 0.5) * 0.5
    }
    
    func convert(to: WeightUnits) -> LiftSet {
        let newWeight = switch (units, to) {
        case (.pounds, .kilograms): 0.453592 * weight
        case (.kilograms, .pounds): 2.20462 * weight
            default: weight
        }
        
        units = to
        return LiftSet(reps: reps, weight: newWeight, units: to)
    }
    
    func weightString() -> String {
        weight == 1.0 ? "**1** \(units.singleUnit)" : "**\(roundedWeight.clean)** \(units.singleUnit)s"
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
