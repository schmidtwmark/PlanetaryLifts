//
//  StickerGeneratorView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/5/24.
//

import SwiftUI
import CrookedText
import Shiny

struct Star: Shape {
    // store how many corners the star has, and how smooth/pointed it is
    let corners: Int
    let smoothness: Double

    func path(in rect: CGRect) -> Path {
        // ensure we have at least two corners, otherwise send back an empty path
        guard corners >= 2 else { return Path() }

        // draw from the center of our rectangle
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

        // start from directly upwards (as opposed to down or to the right)
        var currentAngle = -CGFloat.pi / 2

        // calculate how much we need to move with each star corner
        let angleAdjustment = .pi * 2 / Double(corners * 2)

        // figure out how much we need to move X/Y for the inner points of the star
        let innerX = center.x * smoothness
        let innerY = center.y * smoothness

        // we're ready to start with our path now
        var path = Path()

        // move to our initial position
        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))

        // track the lowest point we draw to, so we can center later
        var bottomEdge: Double = 0

        // loop over all our points/inner points
        for corner in 0..<corners * 2  {
            // figure out the location of this point
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: Double

            // if we're a multiple of 2 we are drawing the outer edge of the star
            if corner.isMultiple(of: 2) {
                // store this Y position
                bottom = center.y * sinAngle

                // …and add a line to there
                path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
            } else {
                // we're not a multiple of 2, which means we're drawing an inner point

                // store this Y position
                bottom = innerY * sinAngle

                // …and add a line to there
                path.addLine(to: CGPoint(x: innerX * cosAngle, y: bottom))
            }

            // if this new bottom point is our lowest, stash it away for later
            if bottom > bottomEdge {
                bottomEdge = bottom
            }

            // move on to the next corner
            currentAngle += angleAdjustment
        }

        // figure out how much unused space we have at the bottom of our drawing rectangle
        let unusedSpace = (rect.height / 2 - bottomEdge) / 2

        // create and apply a transform that moves our path down by that amount, centering the shape vertically
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        return path.applying(transform)
    }
}

extension UIColor {
    static func fromHex(_ hex: UInt64) -> UIColor {
        return UIColor(
              red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(hex & 0x0000FF) / 255.0,
              alpha: CGFloat(1.0)
        )
    }
    
    func toHex() -> UInt64 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        
        
        return UInt64(red * 255.0) << 16 | UInt64(green * 255.0) << 8 | UInt64(blue * 255.0)
    }
}

struct StickerConfig: Codable, Equatable{
    var id: UUID
    var timestamp: Date
    var type: LiftType
    var reps: Int
    var weight: Double
    var units: WeightUnits
    var colorHex: UInt64
    
    var color: UIColor {
        return UIColor.fromHex(colorHex)
    }
    
    func convert(_ to: WeightUnits) -> StickerConfig {
        let newWeight = switch (units, to) {
        case (.pounds, .kilograms): 0.453592 * weight
        case (.kilograms, .pounds): 2.20462 * weight
            default: weight
        }
        
        return StickerConfig(id: self.id, timestamp: self.timestamp, type: self.type, reps: self.reps, weight: newWeight, units: to, colorHex: colorHex)
    }
}

struct StickerView: View {
    var config: StickerConfig
    
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = Locale.current
        return numberFormatter
    }
    
    
    var timestampString: String {
        let month = config.timestamp.formatted(Date.FormatStyle().month(.wide))
        let components = Calendar.current.dateComponents([.day], from: config.timestamp)
        let day = numberFormatter.string(for: components.day!)!
        let year = config.timestamp.formatted(Date.FormatStyle().year())
        
        return [month, day, "", year].joined(separator: " ").uppercased()
    }
    
    
    func scale(_ size: GeometryProxy) -> CGFloat {
        return min(size.size.width, size.size.height)
    }
    
    var body: some View {
        ZStack {
            Star(corners: 50, smoothness: 0.95)
                .shiny(.matte(config.color))
                .aspectRatio(contentMode: .fit)
            Circle().stroke(lineWidth: 5)
                .padding(30)
                .foregroundStyle(Color.white)
            VStack {
                Image(systemName: "dumbbell")
                    .font(.system(size: 150))
                    .foregroundStyle(Color.white)
                Text("\(config.weight.clean) \(config.units.singleUnit)\(config.weight != 1.0 ? "s" : "")")
                
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            }
            CrookedText(text: "PERSONAL BEST - \(config.type.string) - \(config.reps) reps - \(timestampString)".uppercased(), radius: 200)
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .fontWeight(.bold)
        }
        .frame(width: 512, height: 512)
    }
}

struct StickerGeneratorView: View {
    @State var scale = 1.0
    var body: some View {
        VStack {
            StickerView(config: StickerConfig(id: UUID(), timestamp: Date.now, type: .benchPress, reps: 10, weight: 200, units: .pounds, colorHex: UIColor.blue.toHex())).scaleEffect(CGSize(width: scale, height: scale))
            HStack{
                Text("Scale: \(String(format: "%.2f", scale))")
                Slider(value: $scale)
            }
            
        }
        .padding()
    }
    
}

#Preview {
    NavigationStack {
        StickerGeneratorView()
    }
}
