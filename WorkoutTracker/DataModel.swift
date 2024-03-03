//
//  DataModel.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import Foundation
import SwiftData

@Model
final class Workout {
    var name: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Lift.workout)
    var lifts: [Lift]
    
    init(name: String? = nil, lifts: [Lift]) {
        self.name = name
        self.lifts = lifts
    }
}

@Model
final class Lift {
    var type: String
    var category: LiftCategory
    
    var sets: [LiftSet]
    
    var timestamp: Date
    var workout: Workout?
    var equalWeight: Bool = true
    var equalReps: Bool = true
    var weighted: Bool = true
    var notes: String = ""
    
    init(liftType: LiftType, sets: [LiftSet] = [], timestamp: Date, workout: Workout? = nil) {
        self.type = liftType.string
        self.category = liftType.category
        self.sets = sets
        self.timestamp = timestamp
        self.workout = workout
    }
    
    func addSet(_ reps: Int, weight: Double = 0) {
        let set = LiftSet(reps: reps, weight: weight)
        sets.append(set)
    }
    
    func allSetsSame() -> Bool {
        if let first = sets.first {
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight == first.weight})
        } else {
            return false
        }
    }
}

final class LiftSet : Codable, Identifiable {
    var reps: Int
    var weight: Double
    var id: UUID = UUID()
    
    init(reps: Int, weight: Double) {
        self.reps = reps
        self.weight = weight
    }
}

