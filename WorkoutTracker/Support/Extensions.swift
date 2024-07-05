//
//  Extensions.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation

extension String {
    func containsIgnoringCase(_ target: String) -> Bool {
        return self.range(of: target, options: .caseInsensitive) != nil
    }
}


extension String: Identifiable {
    public var id: String {
        self
    }
}



extension Double{
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}

extension Double {
    var roundedWithAbbreviations: String {
        let thousand = self / 1000.0
        let million = self / 1000000.0
        let billion = self / 1000000000.0
        if billion >= 1.0 {
            return "\(((billion * 10).rounded()/10.0).clean)B"
        }
        else if million >= 1.0 {
            return "\(((million * 10).rounded()/10.0).clean)M"
        }
        else if thousand >= 1.0 {
            return "\(((thousand * 10).rounded()/10.0).clean)K"
        }
        else {
            return "\(self.clean)"
        }
    }
}

extension Double {
    func displayString(singleUnit: String) -> String {
        return "\(self.roundedWithAbbreviations) \(singleUnit)\(self.rounded() != 1.0 ? "s" : "")"
    }
}
