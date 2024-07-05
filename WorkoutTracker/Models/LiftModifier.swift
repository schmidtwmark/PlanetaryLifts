//
//  LiftModifier.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation

enum LiftModifier: String, Codable, CaseIterable {
    case incline = "Incline"
    case decline = "Decline"
    case narrowGrip = "Narrow Grip"
    case wideGrip = "Wide Grip"
    case oneArm = "One Arm"
    case reverse = "Reverse"
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case hexBar = "Hex Bar"
    case multiGripBar = "Multi Grip Bar"
    case cable = "Cable"
    case deficit = "Deficit"
    
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
