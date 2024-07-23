//
//  ViewConstants.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/5/24.
//

import Foundation
import SwiftUI

let SILHOUETTE_ASPECT_RATIO = 66.70126342773438 / 143.2188720703125
let CARD_MARGIN = 30.0
let CHART_PADDING = 10.0
let LIST_ROW_VERTICAL_PADDING = 15.0
let TOP_OF_LIST = "Top of List"
let MAX_CARD_WIDTH = 375.0
let SCROLL_DELAY: DispatchTimeInterval = .milliseconds(250)

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension UIApplication {
    var bottomSafeAreaInset: Double {
        Double((self.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0.0)
    }
}

struct ForegroundText : ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .light {
            return Color.black
        } else {
            return Color.white
        }
    }
}

struct SafeAreaBottomPadding: ViewModifier {
    func body(content: Content) -> some View {
        if (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom == 0.0 {
            content.padding(.bottom)
        } else {
            content
        }
    }
}

extension View {
    func safeAreaBottomPadding() -> some View {
        modifier(SafeAreaBottomPadding())
    }
}

