//
//  UserGeneratedLiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation
import SwiftData

@Model
final class UserGeneratedLiftType  {
    var name: String = ""
    var category: LiftCategory = LiftCategory.chest
    var id: UUID = UUID()
    
    struct LiftWeight : Codable {
        var muscleGroup: MuscleGroup
        var weight: Double
    }
    
    var weights: [LiftWeight] = []
    
    var liftWeights: LiftWeights {
        LiftWeights(weights.map({($0.muscleGroup, $0.weight)}))
    }
    
    init(name: String, category: LiftCategory, weights: [(MuscleGroup, Double)] = []) {
        self.name = name
        self.category = category
        self.weights = weights.map({LiftWeight(muscleGroup: $0.0, weight: $0.1)})
    }
}

func generateAllLiftsByCategory(userGeneratedTypes: [UserGeneratedLiftType]) -> [LiftCategory: [LiftType]] {
    var categoryMap = LiftType.liftsByCategory
    for type in userGeneratedTypes {
        categoryMap[type.category]!.append(LiftType.other(name: type.name, category: type.category, id: type.id))
    }
    return categoryMap
}
