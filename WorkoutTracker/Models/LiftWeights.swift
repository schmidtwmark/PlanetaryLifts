//
//  LiftWeights.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation

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
    
    func normalizeByMax() -> LiftWeights {
        guard let max = map.max(by: {$0.value < $1.value}), max.value != 0.0 else { return LiftWeights() }
        
        return LiftWeights(map.map({group, weight in
            (group, weight / max.value)
        }))
    }
    
    func normalizeByMagnitude() -> LiftWeights {
        let magnitude = sqrt(map.reduce(0.0, { sum, item in sum + pow(item.value, 2)}))
        
        return LiftWeights(map.map({ group, weight in
            (group, weight / magnitude)
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

}
