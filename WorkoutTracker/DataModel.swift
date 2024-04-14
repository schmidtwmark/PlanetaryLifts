//
//  DataModel.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Lift {
    var type: LiftType
    
    var sets: [LiftSet]
    
    var timestamp: Date
    var equalWeight: Bool = true
    var equalReps: Bool = true
    var weighted: Bool = true
    var notes: String = ""
    var modifiers: Set<LiftModifier>
    
    init(liftType: LiftType, sets: [LiftSet] = [], timestamp: Date, modifiers: Set<LiftModifier> = Set(), notes: String = "") {
        self.type = liftType
        self.sets = sets
        self.timestamp = timestamp
        self.modifiers = modifiers
        self.notes = notes
    }
    
    func addSet(_ reps: Int, weight: Double, units: WeightUnits) {
        let set = LiftSet(reps: reps, weight: weight, units: units)
        sets.append(set)
    }
    
    func addSet(_ reps: Int, plates: WeightPlates, units: WeightUnits) {
        let set = LiftSet(reps: reps, plates: plates, units: units)
        sets.append(set)
    }
    
    func allSetsSame() -> Bool {
        if let first = sets.first {
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight == first.weight && $0.weight.units == first.weight.units})
        } else {
            return false
        }
    }
    
    // Maps rep count to the maximum weight for that rep count in the given sets
    func maxes() -> [Int: Double] {
        return sets.reduce(into: [Int: Double](), { result, liftSet in
            if let maxForReps = result[liftSet.reps], liftSet.roundedWeight < maxForReps {
                return
            }
            result[liftSet.reps] = liftSet.roundedWeight
        })
    }
}

struct WeightPlates : Codable, Equatable {
    var barWeight: Double
    
    struct Plate : Codable, Equatable, Identifiable, Comparable {
        static func < (lhs: WeightPlates.Plate, rhs: WeightPlates.Plate) -> Bool {
            return lhs.weight < rhs.weight
        }
        
        var id: UUID = UUID()
        var weight: Double
        
    }
    var plates: [Plate]
    var mirrored : Bool = true
    
    var weight: Double {
        barWeight + (mirrored ? 2.0 : 1.0) * plates.reduce(0, { return $0 + $1.weight})
    }
    
}

struct Weight : Equatable, Codable{
    
    enum WeightData : Equatable{
        case rawWeight(Double)
        case plates(WeightPlates)
    }
    
    enum WeightDataTypes: String {
        case rawWeight
        case plates
    }
    
    
    var weight: Double {
        return switch data {
        case .plates(let plates): plates.weight
        case .rawWeight(let weight): weight
        }
    }
    
    var data: WeightData
    var units: WeightUnits
    
    init(data: WeightData, units: WeightUnits) {
        self.data = data
        self.units = units
    }
    
    enum CodingKeys: String, CodingKey {
        case weightType
        case weightData
        case units
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .weightType)
        switch type {
        case WeightDataTypes.plates.rawValue:
            let plates = try values.decode(WeightPlates.self, forKey: .weightData)
            self.data = .plates(plates)
            break
        case WeightDataTypes.rawWeight.rawValue:
            let rawWeight = try values.decode(Double.self, forKey: .weightData)
            self.data = .rawWeight(rawWeight)
            break
        default:
            self.data = .rawWeight(0)
            break
        }
        self.units = try values.decode(WeightUnits.self, forKey: .units)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch data {
        case .rawWeight(let rawWeight):
            try container.encode(rawWeight, forKey: .weightData)
            try container.encode(WeightDataTypes.rawWeight.rawValue, forKey: .weightType)
            break
        case .plates(let plates):
            try container.encode(plates, forKey: .weightData)
            try container.encode(WeightDataTypes.plates.rawValue, forKey: .weightType)
        }
        try container.encode(self.units, forKey: .units)
    }
    
}

struct LiftSet : Codable, Identifiable, Equatable {

    var reps: Int
    var weight: Weight
    
    var id: UUID = UUID()
    
    init(reps: Int, weight: Double, units: WeightUnits) {
        self.reps = reps
        self.weight = Weight(data: .rawWeight(weight), units: units)
    }
            
    init(reps: Int, plates: WeightPlates, units: WeightUnits) {
        self.reps = reps
        self.weight = Weight(data: .plates(plates), units: units)
    }
    
    var roundedWeight : Double {
        round(weight.weight / 0.5) * 0.5
    }
    
    func convert(to: WeightUnits) -> LiftSet {
        let newWeight = switch (weight.units, to) {
        case (.pounds, .kilograms): 0.453592 * weight.weight
        case (.kilograms, .pounds): 2.20462 * weight.weight
        default: weight.weight
        }
        
        return LiftSet(reps: reps, weight: newWeight, units: to)
    }
    
    func weightString() -> String {
        weight.weight == 1.0 ? "**1** \(weight.units.singleUnit)" : "**\(roundedWeight.clean)** \(weight.units.singleUnit)s"
    }
    
}

@Model
final class UserGeneratedLiftType  {
    var name: String
    var category: LiftCategory
    var id: UUID = UUID()
    
    init(name: String, category: LiftCategory) {
        self.name = name
        self.category = category
    }
}

func generateAllLiftsByCategory(userGeneratedTypes: [UserGeneratedLiftType]) -> [LiftCategory: [LiftType]] {
    var categoryMap = LiftType.liftsByCategory
    for type in userGeneratedTypes {
        categoryMap[type.category]!.append(LiftType.other(name: type.name, category: type.category, id: type.id))
    }
    return categoryMap
}


