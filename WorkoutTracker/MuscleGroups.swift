//
//  MuscleGroups.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/23/24.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Comparable, Codable {
    static func < (lhs: MuscleGroup, rhs: MuscleGroup) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case biceps = "Biceps"
    case triceps = "Triceps"
    case trapezius = "Trapezius"
    case latissmusDorsi = "Latissimus Dorsi"
    case forearms = "Forearms"
    case glutes = "Glutes"
    case hamstrings = "Hamstrings"
    case quadriceps = "Quadriceps"
    case calves = "Calves"
    case abs = "Abs"
    case obliques = "Obliques"
    case chest = "Chest"
    case deltoid = "Deltoid"
    case lowerBack = "Lower Back"

    var id: String { self.rawValue }
}

extension MuscleGroup {
    var category: LiftCategory {
        switch self {
        case .biceps, .triceps, .forearms: .arms
        case .deltoid, .trapezius: .shoulders
        case .chest: .chest
        case .abs, .obliques: .core
        case .glutes: .glutes
        case .hamstrings, .calves, .quadriceps: .legs
        case .lowerBack, .latissmusDorsi: .back
        }
    }
}

enum MuscleGroupImpact: String, CaseIterable, Identifiable {
    case noImpact = "No Impact"
    case minorImpact = "Minor Impact"
    case smallImpact = "Small Impact"
    case mediumImpact = "Medium Impact"
    case highImpact = "High Impact"
    
    var id: String {
        self.rawValue
    }
    
    init(weight: Double) {
        if weight >= 1.0 {
            self = .highImpact
        } else if weight >= 0.75 {
            self = .mediumImpact
        } else if weight >= 0.50 {
            self = .smallImpact
        } else if weight >= 0.25 {
            self = .minorImpact
        } else {
            self = .noImpact
        }
    }
    
    var weight: Double {
        switch self {
            
        case .noImpact:
            return 0.0
        case .minorImpact:
            return 0.25
        case .smallImpact:
            return 0.5
        case .mediumImpact:
            return 0.75
        case .highImpact:
            return 1.0
        }
    }
}
