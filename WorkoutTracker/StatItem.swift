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

enum Selection {
    case none
    case maxes(String) // selection of number of reps
    case progress(Date, Double) // Selection of a single progress spot
}

struct MaxesBarChart : View {
    
    var maxes: [Int: Double]
    var colorByRepCount: [String: Color]
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    @Binding var selection: Selection
    
    var body: some View {
        Chart {
            ForEach(maxes.sorted(by: <), id: \.key) { reps, max in
                BarMark(x: .value("Reps", repToString(reps)), y: .value("Weight", max))
                    .annotation(content: {
                        if case let .maxes(selectedReps) = selection, selectedReps == repToString(reps) {
                            Text("\(max.roundedWithAbbreviations) \(weightUnits.shortSingleUnit)\(max.rounded() != 1.0 ? "s" : "")")
                        }
                    })
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
                                    if let item = proxy.value(at: location, as: (String, Double).self) {
                                        if case let .maxes(selectedReps) = selection,  selectedReps == item.0 {
                                            selection = .none
                                        } else {
                                            selection = .maxes(item.0)
                                        }
                                    }
                                }
                        )
                    
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
    @State var selection: Selection = .none
    @State var timeWindow: TimeWindow = .week
    
    enum TimeWindow : String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case ninetyDays = "90 Days"
        case year = "Year"
        
        var timeRange: Int {
            let days = switch self {
            case .week:
                7
            case .month:
                30
            case .ninetyDays:
                90
            case .year:
                365
            }
            return 60 * 60 * 24 * days
            
        }
    }


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
                    MaxesBarChart(maxes: maxes, 
                                  colorByRepCount: colorByRepCount,
                                  selection: $selection)
                    .frame(minWidth: 150, minHeight: 200)
                }
                
                Section("Progress") {
                    Picker("Time Window", selection: $timeWindow) {
                        ForEach(TimeWindow.allCases, id: \.rawValue) {
                            Text($0.rawValue).tag($0)
                        }
                    }
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
                    .chartXVisibleDomain(length: timeWindow.timeRange)
                    .chartYScale(domain: 0...max * 1.4)
                    .chartScrollPosition(initialX: Date().addingTimeInterval(TimeInterval(-1 * timeWindow.timeRange)))
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
