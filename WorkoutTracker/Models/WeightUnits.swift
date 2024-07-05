//
//  WeightUnits.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation

enum WeightUnits : String, Codable, Equatable{
    case pounds = "Pounds"
    case kilograms = "Kilograms"
    
    var singleUnit: String {
        switch self {
            case .pounds: "pound"
            case .kilograms: "kilogram"
        }
    }
    
    var shortSingleUnit: String {
        switch self {
        case .pounds: "lb"
        case .kilograms: "kg"
        }
    }
}
