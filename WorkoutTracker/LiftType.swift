//
//  LiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import Foundation


enum LiftCategory: String, Codable, CaseIterable {
    case back = "Back"
    case chest = "Chest"
    case arms = "Arms"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case core = "Core"
    case other = "Other"
}

enum LiftType: Hashable, Codable {
    
    
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
    
    static var allCases: [LiftType] = [
        .latPullDown,
        .benchPress,
        .dumbbellCurl,
        .reverseDumbbellCurl,
        .weightedBarCurl,
        .reverseWeightedBarCurl,
        .deadlift,
        .backSquat,
        .frontSquat,
        .shoulderPress,
        .sitUp]
    
    static var liftsByCategory: [LiftCategory: [LiftType]] {
        var map : [LiftCategory: [LiftType]] = [:]
        for category in LiftCategory.allCases {
           map[category] = []
        }
        for liftType in allCases {
            map[liftType.category]?.append(liftType)
        }
        return map
    }
    
    var string : String {
        return switch self {
        // MARK: back
        case .latPullDown: "Lat Pull Down"
        
        // MARK: chest
        case .benchPress: "Bench Press"
        
        // MARK: arms
        case .dumbbellCurl: "Dumbbell Curl"
        case .reverseDumbbellCurl: "Reverse Dumbbell Curl"
        case .weightedBarCurl: "Weighted Bar Curl"
        case .reverseWeightedBarCurl: "Reverse Weighted Bar Curl"
        
        // MARK: legs
        case .deadlift: "Deadlift"
        case .backSquat: "Back Squat"
        case .frontSquat: "Front Squat"
        
        // MARK: shoulders
        case .shoulderPress: "Shoulder Press"
       
        // MARK: core
        case .sitUp: "Sit Ups"
            
        case .other(let name, _): name
        }
    }
    
    var category: LiftCategory {
        return switch self {
        // MARK: back
        case .latPullDown: .back
        
        // MARK: chest
        case .benchPress: .chest
        
        // MARK: arms
        case .dumbbellCurl: .arms
        case .reverseDumbbellCurl: .arms
        case .weightedBarCurl: .arms
        case .reverseWeightedBarCurl: .arms
        
        // MARK: legs
        case .deadlift: .legs
        case .backSquat: .legs
        case .frontSquat: .legs
        
        // MARK: shoulders
        case .shoulderPress: .shoulders
            
        // MARK: core
        case .sitUp: .core
            
            
        case .other(_, let category): category
        }
    }
    
}
