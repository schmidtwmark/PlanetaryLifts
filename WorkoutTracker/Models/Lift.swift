//
//  DataModel.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import Foundation
import SwiftData

@Model
final class Lift {
    var type: LiftType = LiftType.benchPress
    
    var sets: [LiftSet] = Array<LiftSet>()
    
    var timestamp: Date = Date.now
    var equalWeight: Bool = true
    var equalReps: Bool = true
    var weighted: Bool = true
    var notes: String = ""
    var modifiers: Set<LiftModifier> = Set<LiftModifier>()
    
    init(liftType: LiftType, sets: [LiftSet] = [], timestamp: Date, modifiers: Set<LiftModifier> = Set(), notes: String = "", weighted: Bool = true) {
        self.type = liftType
        self.sets = sets
        self.timestamp = timestamp
        self.modifiers = modifiers
        self.notes = notes
        self.weighted = weighted
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
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight.weight == first.weight.weight && $0.weight.units == first.weight.units})
        } else {
            return false
        }
    }
    
    var recencyFactor: Double {
        let daysSince = Date().timeIntervalSince(self.timestamp) / (60 * 60 * 24)
        return (-1.0 / 7.0) * daysSince + 1.0
    }
    
    struct LiftPoint : Hashable {
        var reps: Int
        var weight: Double
    }
    
    func uniqueSets() -> [LiftSet] {
        let uniqueSets = sets.reduce(into: Set<LiftPoint>(), { result, liftSet in
            result.insert(LiftPoint(reps: liftSet.reps, weight: liftSet.weight.weight))
        })
        
        return sets.filter({liftSet in
            uniqueSets.contains(LiftPoint(reps: liftSet.reps, weight: liftSet.weight.weight))
        })
    }
    
    // Maps rep count to the maximum weight for that rep count in the given sets
    func maxes() -> [Int: Double] {
        return sets.reduce(into: [Int: Double](), { result, liftSet in
            if let maxForReps = result[liftSet.reps], liftSet.weight.roundedWeight < maxForReps {
                return
            }
            if self.weighted {
                result[liftSet.reps] = liftSet.weight.roundedWeight
            } else {
                result[liftSet.reps] = 0
            }
        })
    }
    
    var date: TimelessDate {
        self.timestamp.timeless()
    }
    
    public var description: String {
        "Lift: \(type.string)"
    }
    
    static func lastWeek() -> Predicate<Lift> {
        
        let now = Date()
        let oneWeekAgo = now.addingTimeInterval(-1 * 60 * 60 * 24 * 7)
//        let calendar = Calendar.autoupdatingCurrent
//        let oneWeekAgo = calendar.date(byAdding: .init(day: -7), to: Date())!
        
        return #Predicate<Lift> { lift in
            lift.timestamp > oneWeekAgo
        }
    }
    
    // If this is a user generated type, we need to get the muscle groups from there
    func getLiftWeights(_ userGeneratedTypes: [UserGeneratedLiftType]) -> LiftWeights {
        // Overrides
        
        return type.getLiftWeights(userGeneratedTypes)
    }
}

struct WeightPlates : Codable, Equatable, CustomStringConvertible {
    var description: String {
        "Bar: \(barWeight) Plates: [\(plates.map({ "\($0.weight)"}).joined(separator: ", "))]"
    }
    
    var barWeight: Double
    
    struct Plate : Codable, Equatable, Identifiable, Comparable {
        static func < (lhs: WeightPlates.Plate, rhs: WeightPlates.Plate) -> Bool {
            return lhs.weight < rhs.weight
        }
        
        var id: UUID = UUID()
        var weight: Double
        
        func clone() -> Plate {
            return Plate(weight: self.weight)
        }
        
    }
    var plates: [Plate]
    var mirrored : Bool = true
    
    func clone() -> WeightPlates {
        return WeightPlates(barWeight: self.barWeight, plates: plates.map({$0.clone()}), mirrored: self.mirrored)
    }
    
    var weight: Double {
        barWeight + (mirrored ? 2.0 : 1.0) * plates.reduce(0, { return $0 + $1.weight})
    }
    
    static func * (multiplier: Double, plates: WeightPlates) -> WeightPlates {
        return WeightPlates(barWeight: plates.barWeight * multiplier, plates: plates.plates.map({Plate(id: $0.id, weight: $0.weight * multiplier)}), mirrored: plates.mirrored)
    }
}

struct Weight : Equatable, Codable{
    
    enum WeightData : Equatable{
        case rawWeight(Double)
        case plates(WeightPlates)
        
        func clone() -> WeightData {
            switch self {
            case .rawWeight(let rawWeight):
                return .rawWeight(rawWeight)
            case .plates(let plates):
                return .plates(plates.clone())
            }
        }
        
        static func * (multiplier: Double, data: WeightData) -> WeightData {
            switch data {
            case .plates(let plates): WeightData.plates(multiplier * plates)
            case .rawWeight(let weight): WeightData.rawWeight(multiplier * weight)
            }
        }
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
    
    var displayString : String {
        self.weight == 1.0 ? "**1** \(self.units.singleUnit)" : "**\(roundedWeight.clean)** \(self.units.singleUnit)s"
    }
    
    var roundedWeight : Double {
        round(self.weight / 0.5) * 0.5
    }
    
    init(data: WeightData, units: WeightUnits) {
        self.data = data
        self.units = units
    }
    
    func clone() -> Weight {
        return Weight(data: self.data.clone(), units: self.units)
    }
    
    func same(other: Weight) -> Bool {
        let sameWeight =  switch (self.data, other.data) {
        case (.plates(let selfPlates), .plates(let otherPlates)):
            selfPlates.mirrored == otherPlates.mirrored && selfPlates.barWeight == otherPlates.barWeight && selfPlates.plates.elementsEqual(otherPlates.plates, by: {$0.weight == $1.weight})
        case (.rawWeight(let selfWeight), .rawWeight(let otherWeight)):
            selfWeight == otherWeight
        default:
            false
        }
        return sameWeight && self.units == other.units
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
    
    init(reps: Int, weight: Weight) {
        self.reps = reps
        self.weight = weight
    }
    
    // Copies with a new ID
    func clone() -> LiftSet {
        return LiftSet(reps: self.reps, weight: self.weight)
    }
    
    
    func convert(to: WeightUnits) -> LiftSet {
        let newWeightData = switch (weight.units, to) {
        case (.pounds, .kilograms): 0.453592 * weight.data
        case (.kilograms, .pounds): 2.20462 * weight.data
        default: weight.data
        }
        return LiftSet(reps: reps, weight: Weight(data: newWeightData, units: to))
    }
}
