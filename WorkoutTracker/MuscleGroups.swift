//
//  MuscleGroups.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/23/24.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable {
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
