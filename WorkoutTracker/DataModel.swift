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
    var lifts: [Lift]
    
    init(name: String? = nil, lifts: [Lift]) {
        self.name = name
        self.lifts = lifts
    }
}

@Model
final class Lift {
    var type: String
    var sets: [LiftSet]
    var timestamp: Date
    
    init(type: String, sets: [LiftSet], timestamp: Date) {
        self.type = type
        self.sets = sets
        self.timestamp = timestamp
    }
}

@Model 
final class LiftSet {
    var reps: Int
    var weight: Double?
    
    init(reps: Int, weight: Double? = nil) {
        self.reps = reps
        self.weight = weight
    }
}
