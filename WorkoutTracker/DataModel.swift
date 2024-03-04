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
