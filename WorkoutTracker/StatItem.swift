//
//  StatItem.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/3/24.
//

import SwiftUI
import Charts

func repToString(_ reps: Int) -> String {
    if reps == 1 {
        return "1 rep"
    } else {
        return "\(reps) reps"
    }
}

struct MaxesBarChart : View {
    
    var maxes: [Int: Double]
    var colorByRepCount: [String: Color]
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    
    
    @State var selectedPosition: (String, Double)? = nil
    var body: some View {
        Chart {
            ForEach(maxes.sorted(by: <), id: \.key) { reps, max in
                BarMark(x: .value("Reps", repToString(reps)), y: .value("Weight", max))
                    .foregroundStyle(by: .value("Reps", repToString(reps)))
            }
        }
        .chartForegroundStyleScale(mapping: { data in
            return colorByRepCount[data]!
        })
        .chartOverlay { proxy in
            GeometryReader { geometry in
                ZStack {
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onEnded{ value in
                                    // Convert the gesture location to the coordiante space of the plot area.
                                    let origin = geometry[proxy.plotFrame!].origin
                                    let location = CGPoint(
                                        x: value.location.x - origin.x,
                                        y: value.location.y - origin.y
                                    )
                                    // Get the x (date) and y (price) value from the location.
                                    if let selection = proxy.value(at: location, as: (String, Double).self) {
                                        selectedPosition = selection
                                    } else {
                                        print("Tap at \(location) is invalid")
                                    }
                                }
                        )
                    if let selection = selectedPosition, let position = proxy.position(for: selection) {
                        Text("Selection: \(selection)").position(position)
                    }
                    
                }
            }
        }
    }
}



struct StatItem: View {
    @State var expanded = true
    var type: LiftType
    var lifts: [Lift]
    
    @State var position: (Date, Double)? = nil
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    @AppStorage(PALETTE) var palette: Palette = .main
    

    var maxes: [Int: Double]{
        return lifts.reduce(into: [Int: Double](), { result, lift in
            let liftMaxes = lift.maxes()
            for (reps, maxWeight) in liftMaxes {
                if let maxForReps = result[reps], maxWeight < maxForReps {
                    return
                }
                result[reps] = maxWeight

            }
        })
    }
    
    var colorByRepCount: [String: Color] {
        let baseColor = type.category.getColor(for: palette)
        
        let shades = baseColor.shades(count: maxes.count)
        return zip(shades, maxes.sorted(by: <)).reduce(into: [String: Color](), { dict, values in
            let (color, (reps, _)) = values
            dict[repToString(reps)] = color
        })
    }
    
    var allTimeMax: Double? {
        maxes.values.max()
    }
    
    var body: some View {
        List {
            if let max = allTimeMax {
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
                        StatBlock(description: "All Time Max", unit: weightUnits.shortSingleUnit, number: max)
                        StatBlock(description: "Total Weight", unit: weightUnits.shortSingleUnit, number: totalWeight(lifts))
                        StatBlock(description: "Total Reps", unit: "Rep", number: Double(totalReps(lifts)))
                        StatBlock(description: "Total Lifts", unit: "Lift", number: Double(lifts.count))
                        
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section("Maxes") {
                    MaxesBarChart(maxes: maxes, colorByRepCount: colorByRepCount)
                    .frame(minWidth: 150, minHeight: 200)
                }
                
                Section("Progress") {
                    Chart(lifts) { lift in
                        ForEach(lift.maxes().sorted(by: <), id: \.key) { reps, maximum in
                            PointMark(x: .value("Date", lift.timestamp, unit: .day), y:
                                    .value(repToString(reps), maximum))
                                .symbol(.circle)
                                .foregroundStyle(by: .value("Reps", repToString(reps)))
                        }
                    }
                    .chartForegroundStyleScale(mapping: { data in
                        return colorByRepCount[data]!
                    })
                    .chartYScale(domain: 0...max * 1.4)
                    .chartScrollableAxes(.horizontal)
                    .chartScrollTargetBehavior(
                        .valueAligned(matching: .init(day: 0))
                    )
                    .frame(minWidth: 150, minHeight: 200)
                }
            }
        }
        .navigationTitle(type.string)
    }
    
    func updateCursorPosition(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        
        let origin = geometry[proxy.plotFrame!].origin
        let datePos = proxy.value(atX: at.x - origin.x, as: Date.self)
        let firstGreater = lifts.lastIndex(where: { $0.timestamp < datePos! })
        if let index = firstGreater {
          let time = lifts[index].timestamp
            let weight = lifts[index].maxes().values.first!
          position = (time, weight)
        }
      }
}

#Preview {
    var lifts: [Lift] = []
    
    for days in 0...50 {
        let lift = Lift(liftType: .benchPress, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
        lifts.append(lift)
        
        lift.addSet(5, weight: Double.random(in: 150...250), units: .pounds)
        lift.addSet(10, weight: Double.random(in: 100...200), units: .pounds)
        lift.addSet(15, weight: Double.random(in: 50...150), units: .pounds)
    }
    
    return NavigationStack {
        StatItem(type: .benchPress, lifts: lifts)
    }
}
