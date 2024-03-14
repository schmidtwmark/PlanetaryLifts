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
    
    init(liftType: LiftType, sets: [LiftSet] = [], timestamp: Date, modifiers: Set<LiftModifier> = Set()) {
        self.type = liftType
        self.sets = sets
        self.timestamp = timestamp
        self.modifiers = modifiers
    }
    
    func addSet(_ reps: Int, weight: Double, units: WeightUnits, sticker: StickerConfig? = nil) {
        let set = LiftSet(reps: reps, weight: weight, units: units, sticker: sticker)
        sets.append(set)
    }
    
    func allSetsSame() -> Bool {
        if let first = sets.first {
            return sets.count >= 2 && sets.allSatisfy({ $0.reps == first.reps && $0.weight == first.weight && $0.units == first.units})
        } else {
            return false
        }
    }
    
    var stickers: [StickerConfig] {
        sets.compactMap({$0.sticker})
    }
}

final class LiftSet : Codable, Identifiable {
    var reps: Int
    var weight: Double
    var units: WeightUnits
    var sticker: StickerConfig? = nil
    
    var id: UUID = UUID()
    
    init(reps: Int, weight: Double, units: WeightUnits, sticker: StickerConfig? = nil) {
        self.reps = reps
        self.weight = weight
        self.units = units
        self.sticker = sticker
    }
    
    var roundedWeight : Double {
        round(weight / 0.5) * 0.5
    }
    
    func convert(to: WeightUnits) -> LiftSet {
        let newWeight = switch (units, to) {
        case (.pounds, .kilograms): 0.453592 * weight
        case (.kilograms, .pounds): 2.20462 * weight
            default: weight
        }
        
        units = to
        return LiftSet(reps: reps, weight: newWeight, units: to, sticker: sticker?.convert(to))
    }
    
    func weightString() -> String {
        weight == 1.0 ? "**1** \(units.singleUnit)" : "**\(roundedWeight.clean)** \(units.singleUnit)s"
    }
    
    func checkSticker(awardMap: AwardMap, lift: Lift) {
        sticker = nil
        let key = AwardKey(reps: self.reps, type: lift.type, modifiers: lift.modifiers)
        print("Checking sticker for key \(key.type) \(key.modifiers) \(key.reps)")
        if let (awardWeight, _) = awardMap[key] {
            if self.weight > awardWeight {
                print("Adding sticker because \(self.weight) is greater than \(awardWeight)")
                self.sticker = StickerConfig(id: UUID(), timestamp: lift.timestamp, type: lift.type, reps: self.reps, weight: self.weight, units: self.units, colorHex: UIColor.green.toHex())
//                awardMap.updateValue((self.weight, self.id), forKey: key)
            } else {
                print("Not adding sticker, \(self.weight) is less than or equal to \(awardWeight)")
            }
        } else {
            print("Adding sticker because empty key")
            self.sticker = StickerConfig(id: UUID(), timestamp: lift.timestamp, type: lift.type, reps: self.reps, weight: self.weight, units: self.units, colorHex: UIColor.green.toHex())
//            awardMap.updateValue((self.weight, self.id), forKey: key)
        }
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


final class AwardKey : Hashable {
    static func == (lhs: AwardKey, rhs: AwardKey) -> Bool {
        return lhs.reps == rhs.reps && lhs.type == rhs.type && lhs.modifiers.elementsEqual(rhs.modifiers)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modifiers)
    }
    
    var reps: Int
    var type: LiftType
    var modifiers: Set<LiftModifier>
    
    init(reps: Int, type: LiftType, modifiers: Set<LiftModifier>) {
        self.reps = reps
        self.type = type
        self.modifiers = modifiers
    }
}

typealias AwardMap = [AwardKey: (Double, UUID)]
// Builds a map from a combination of lift type, lift modifiers, and number of reps
// Value is the maximum for that type and the id for that specific set
func generateAwardMap(_ lifts: [Lift]) -> AwardMap {
    var map : AwardMap = [:]
    lifts.forEach({ lift in
        for set in lift.sets {
            let key = AwardKey(reps: set.reps, type: lift.type, modifiers: lift.modifiers)
            if let value = map[key] {
                if set.weight > value.0 {
                    map.updateValue((set.weight, set.id), forKey: key)
                }
            } else {
                map.updateValue((set.weight, set.id), forKey: key)
            }
        }
    })
    print("Generated award map:")
    for (key, value) in map {
        print("\(key.type) \(key.modifiers) \(key.reps): \(value.0)")
    }
    return map
}
