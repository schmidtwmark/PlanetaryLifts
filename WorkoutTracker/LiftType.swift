//
//  LiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import Foundation
import SwiftUI
import Charts


public enum LiftCategory: String, Codable, CaseIterable, Comparable {
    public static func < (lhs: LiftCategory, rhs: LiftCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case back = "Back"
    case chest = "Chest"
    case arms = "Arms"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case core = "Core"
    case glutes = "Glutes"
    case other = "Other"
}

extension LiftCategory {
    func getColor(for palette: Palette) -> Color {
        palette.getColor(forCategory: self)
    }
}

extension LiftCategory : Plottable {
    
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
    case hexBar = "Hex Bar"
    case multiGripBar = "Multi Grip Bar"
    case cable = "Cable"
    
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

extension LiftType: Comparable {
    static func < (lhs: LiftType, rhs: LiftType) -> Bool {
        lhs.string < rhs.string
    }
}

extension LiftType {
    var deletable: Bool {
        return switch self {
        case .other(_, _, _): true
            default: false
        }
    }
    
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
}
