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
    case glutes = "Glutes"
    case other = "Other"
}


enum LiftModifier: String, Codable, CaseIterable {
    case incline = "Incline"
    case decline = "Decline"
    case narrowGrip = "Narrow Grip"
    case wideGrip = "Wide Grip"
    case oneArm = "One Arm"
    case reverse = "Reverse"
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    
    // For any given modifier, returns the set of modifiers that cannot also be set
    // You can't do Incline Decline Bench
    var exclusions: Set<LiftModifier> {
        return switch self {
        case .incline: Set([.decline])
        case .decline: Set([.incline])
        case .narrowGrip: Set([.wideGrip])
        case .wideGrip: Set([.narrowGrip])
        default: Set()
        }
    }
}

enum LiftType: Hashable, Codable{
    // MARK: back
    case latPullDown
    
    // MARK: chest
    case benchPress
    
    // MARK: arms
    case dumbbellCurl
    case weightedBarCurl
    
    // MARK: legs
    case deadlift
    case backSquat
    case frontSquat
    
    // MARK: shoulders
    case shoulderPress
   
    // MARK: core
    case sitUp
    
    // MARK: glutes
    
    // MARK: other
    
    
    
    // MARK: user specified
    case other(name: String, category: LiftCategory, id: UUID)
    
    static var allCases: [LiftType] = [
        .latPullDown,
        .benchPress,
        .dumbbellCurl,
        .weightedBarCurl,
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
        case .weightedBarCurl: "Weighted Bar Curl"
        
        // MARK: legs
        case .deadlift: "Deadlift"
        case .backSquat: "Back Squat"
        case .frontSquat: "Front Squat"
        
        // MARK: shoulders
        case .shoulderPress: "Shoulder Press"
       
        // MARK: core
        case .sitUp: "Sit Ups"
            
        case .other(let name, _, _): name
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
        case .weightedBarCurl: .arms
        
        // MARK: legs
        case .deadlift: .legs
        case .backSquat: .legs
        case .frontSquat: .legs
        
        // MARK: shoulders
        case .shoulderPress: .shoulders
            
        // MARK: core
        case .sitUp: .core
            
            
        case .other(_, let category, _): category
        }
    }
    
    var deletable: Bool {
        return switch self {
            case .other(_, _, _): true
            default: false
        }
    }
    
    var modifiers: [LiftModifier] {
        return switch self {
        case .benchPress: [.incline, .decline]
        default: []
        }
    }
}
