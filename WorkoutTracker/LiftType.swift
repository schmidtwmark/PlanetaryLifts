//
//  LiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import Foundation


enum LiftCategory: String, Codable {
    case back = "Back"
    case chest = "Chest"
    case arms = "Arms"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case core = "Core"
    case other = "Other"
}

enum LiftType {
    // MARK: back
    case latPullDown
    
    // MARK: chest
    case benchPress
    
    // MARK: arms
    case dumbbellCurl
    case reverseDumbbellCurl
    case weightedBarCurl
    case reverseWeightedBarCurl
    
    // MARK: legs
    case deadlift
    case backSquat
    case frontSquat
    
    // MARK: shoulders
    case shoulderPress
   
    // MARK: core
    case sitUp
    
    // MARK: other
    
    
    // MARK: user specified
    case other(name: String, category: LiftCategory)
    
    
    var string : String {
        return switch self {
        case .latPullDown: "Lat Pull Down"
        case .benchPress: "Bench Press"
        case .backSquat: "Back Squat"
        case .other(let name, _): name
        default: "NOT YET IMPLEMENTED"
        }
    }
    
    var category: LiftCategory {
        return switch self {
        case .latPullDown: .back
        case .benchPress: .chest
        case .backSquat: .legs
        case .other(_, let category): category
        default: .other
        }
    }
    
}
