//
//  Palette.swift
//  GoodVibesOnly
//
//  Created by Mark Schmidt on 7/20/23.
//

import Foundation
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}


public enum Palette : String, CaseIterable {
    case main = "Main"
    
}

extension Palette {
    private func getColorByName(_ paletteString: String, _ category: LiftCategory) -> Color? {
        let fullName = paletteString + "/" + category.rawValue
        
        return if let uiColor = UIColor(named: fullName) {
            Color(uiColor: uiColor)
        } else {
            nil
        }
    }
    
    public func getColors() -> [LiftCategory: Color] {
        let paletteName = self.rawValue
        return LiftCategory.allCases.reduce(into: [LiftCategory: Color](), {
            $0[$1] = getColorByName(paletteName, $1)
        })
    }
    
//    
//    public func accentColor(colorScheme: ColorScheme) -> Color {
//        switch colorScheme {
//            case .dark:
//                return brightestColor
//            case .light:
//                return darkestColor
//        @unknown default:
//            fatalError("Unknown color scheme")
//        }
//    }
    
}


