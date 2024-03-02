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
    
    @Relationship(deleteRule: .cascade, inverse: \LiftSet.lift)
    var sets: [LiftSet]
    
    var orderedSets : [LiftSet] {
        return sets.sorted(by:  {$0.order < $1.order })
    }
    var timestamp: Date
    var workout: Workout?
    var equalWeight: Bool = true
    var equalReps: Bool = true
    var weighted: Bool = true
    var notes: String = ""
    
    init(type: String, sets: [LiftSet], timestamp: Date, workout: Workout? = nil) {
        self.type = type
        self.sets = sets
        self.timestamp = timestamp
        self.workout = workout
    }
    
    func addSet(_ reps: Int, weight: Double? = nil) {
        let order = if let lastSet = orderedSets.last {
            lastSet.order + 1
        } else {
            0
        }
        
        let set = LiftSet(reps: reps, weight: weight, lift: self, order: order)
        sets.append(set)
    }
}

@Model
final class LiftSet {
    var reps: Int
    var weight: Double?
    var lift: Lift?
    var order = 0
    
    init(reps: Int, weight: Double? = nil, lift: Lift? = nil, order: Int = 0) {
        self.reps = reps
        self.weight = weight
        self.lift = lift
        self.order = order
    }
}

