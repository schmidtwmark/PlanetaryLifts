//
//  ColorAdjustment.swift
//  GoodVibesOnly
//
//  Created by Mark Schmidt on 7/13/23.
//

import Foundation
import SwiftUI

extension Color {
    
    init(hex: UInt64) {
        self.init(uiColor: UIColor(
              red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(hex & 0x0000FF) / 255.0,
              alpha: CGFloat(1.0)
            )
        )
      }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {

           #if canImport(UIKit)
           typealias NativeColor = UIColor
           #elseif canImport(AppKit)
           typealias NativeColor = NSColor
           #endif

           var r: CGFloat = 0
           var g: CGFloat = 0
           var b: CGFloat = 0
           var o: CGFloat = 0
        
           guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
               // You can handle the failure here as you want
               return (0, 0, 0, 0)
           }

           return (r, g, b, o)
       }
    
    var hsv: (hue: CGFloat, saturation: CGFloat, value: CGFloat, alpha: CGFloat) {
        
           #if canImport(UIKit)
           typealias NativeColor = UIColor
           #elseif canImport(AppKit)
           typealias NativeColor = NSColor
           #endif

           var h: CGFloat = 0
           var s: CGFloat = 0
           var v: CGFloat = 0
           var o: CGFloat = 0
        
           guard NativeColor(self).getHue(&h, saturation: &s, brightness: &v, alpha: &o) else {
               // You can handle the failure here as you want
               return (0, 0, 0, 0)
           }

           return (h, s, v, o)
    }

    func lighter(by percentage: CGFloat = 30.0) -> Color {
        let hsv = self.hsv
        let output = Color(hue: hsv.hue, saturation: max(min(hsv.saturation - percentage / 100, 1.0), 0.0), brightness: hsv.value, opacity: hsv.alpha)
        return output
    }

    func darker(by percentage: CGFloat = 30.0) -> Color {
        let hsv = self.hsv
        let output = Color(hue: hsv.hue, saturation: hsv.saturation, brightness: max(min(hsv.value - percentage / 100, 1.0), 0.0), opacity: hsv.alpha)
        return output
    }

    func gradient(other: Color, percentage: Double) -> Color {
        let hsv = self.hsv
        let otherHsv = other.hsv
        let output = Color(hue: hsv.hue + (otherHsv.hue - hsv.hue) * percentage,
                           saturation: hsv.saturation + (otherHsv.saturation - hsv.saturation) * percentage,
                           brightness: hsv.value + (otherHsv.value - hsv.value) * percentage,
                           opacity: hsv.alpha + (otherHsv.alpha - hsv.alpha) * percentage)
        return output
    }
    
    // Generate a list of shades that are close to this one
    func shades(count: Int) -> [Color] {
        let delta = count <= 7 ? 20 : 60 / Double(count)
        
        
        let midpoint = count / 2
        let darker = (0..<midpoint).map({ index in
            let darker = delta * Double(index + 1)
            return self.darker(by: darker)
        }).reversed()
        
        let lighter = ((midpoint + 1)..<count).map({ index in
            let lighter = delta * Double(index - midpoint)
            return self.lighter(by: lighter)
        })
        
        let maybeMiddle = lighter.count + darker.count == count ? [] : [self]
        let output = darker + maybeMiddle + lighter
        return output
        
    }
    

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    var brightness : CGFloat {
        self.hsv.value
    }
    
    func background(scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            self.lighter(by: 30.0)
        case .dark:
            self.darker(by: 30.0)
        @unknown default:
            self
        }
    }
}
