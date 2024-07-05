//
//  LiftType.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import Foundation


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

extension LiftType: Comparable {
    static func < (lhs: LiftType, rhs: LiftType) -> Bool {
        lhs.string < rhs.string
    }
}
