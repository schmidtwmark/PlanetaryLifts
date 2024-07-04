//
//  LiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
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

extension LiftType : Identifiable {
    var id: String {
        switch self {
        case .other(_, _, let uuid):
            uuid.uuidString
        default: 
            self.string
        }
    }
    
}

protocol Defaultable {
    init()
}

extension LiftType: Defaultable {
    init() {
        self = .backSquat
    }
}

extension LiftCategory: Defaultable {
    init() {
        self = .back
    }
}

struct LiftWeights : Codable, Equatable, Hashable {
    var map: [MuscleGroup: Double] = [:]
    
    init(_ sparse: [(MuscleGroup, Double)] = []) {
        map = sparse.reduce(into: [MuscleGroup: Double](), {result, item in
            result[item.0] = item.1
        })
        MuscleGroup.allCases.forEach({ group in
            if let _ = map[group] { return }
            map[group] = 0.0
        })
    }
    
    mutating func add(_ muscleGroup: MuscleGroup, score: Double) {
        map[muscleGroup]! += score
    }
    
    func getWeight(_ muscleGroup: MuscleGroup) -> Double {
        return map[muscleGroup]!
    }
    
    func normalize() -> LiftWeights {
        guard let max = map.max(by: {$0.value < $1.value}), max.value != 0.0 else { return LiftWeights() }
        
        return LiftWeights(map.map({group, weight in
            (group, weight / max.value)
        }))
    }
    
    var mean: Double {
        map.map({$1}).reduce(0.0, +) / Double(map.count)
    }
    
    func affects(_ muscleGroup: MuscleGroup?) -> Bool {
        if let group = muscleGroup {
            return getWeight(group) != 0.0
        }
        return true
    }
    
    // Muscle groups with weights sorted by largest to smallest impact
    var sortedGroups: [(MuscleGroup, Double)] {
        map.filter({$0.value > 0.0}).map({($0.key, $0.value)}).sorted(by: {
            ($0.1, $0.0) > ($1.1, $1.0)
        })
    }
    
    func dotProduct(_ other: LiftWeights) -> Double {
        return MuscleGroup.allCases.reduce(0.0, { sum, group in sum + self.getWeight(group) * other.getWeight(group)})
    }
    
    func suggestionScore(_ current: LiftWeights) -> Double {
        return MuscleGroup.allCases.reduce(0.0, {sum, group in sum + (self.getWeight(group) - current.getWeight(group))})
    }
}
