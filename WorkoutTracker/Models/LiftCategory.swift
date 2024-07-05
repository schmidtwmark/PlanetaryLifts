//
//  LiftCategory.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation
import SwiftUI
import Charts

public enum LiftCategory: String, Codable, CaseIterable, Comparable, Identifiable, Sendable {
    public var id: String {
        self.rawValue
    }
    
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
