//
//  LiftGroup.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/11/26.
//

import Foundation
import SwiftData

@Model
final class LiftGroup {
    var name: String = ""
    var id: UUID = UUID()
    var createdAt: Date = Date.now
    var lifts: [SavedLift] = Array<SavedLift>()

    // A snapshot of a Lift, stored by value so groups are independent
    // of the lifts they were created from
    struct SavedLift: Codable, Identifiable, Equatable {
        var type: LiftType
        var sets: [LiftSet]
        var modifiers: Set<LiftModifier>
        var notes: String
        var weighted: Bool
        var id: UUID = UUID()

        init(from lift: Lift) {
            self.type = lift.type
            self.sets = lift.sets.map({$0.clone()})
            self.modifiers = lift.modifiers
            self.notes = lift.notes
            self.weighted = lift.weighted
        }

        func makeLift(timestamp: Date) -> Lift {
            return Lift(liftType: type,
                        sets: sets.map({$0.clone()}),
                        timestamp: timestamp,
                        modifiers: modifiers,
                        notes: notes,
                        weighted: weighted)
        }
    }

    init(name: String, lifts: [Lift]) {
        self.name = name
        self.lifts = lifts.map({SavedLift(from: $0)})
    }
}
