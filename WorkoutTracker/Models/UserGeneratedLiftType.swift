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
    
    var customWeights: LiftWeights = LiftWeights([])
    
    init(name: String, category: LiftCategory, liftWeights: LiftWeights = LiftWeights()) {
        self.name = name
        self.category = category
        self.customWeights = liftWeights
    }
}

func generateAllLiftsByCategory(userGeneratedTypes: [UserGeneratedLiftType]) -> [LiftCategory: [LiftType]] {
    var categoryMap = LiftType.liftsByCategory
    for type in userGeneratedTypes {
        categoryMap[type.category]!.append(LiftType.other(name: type.name, category: type.category, id: type.id))
    }
    return categoryMap
}
