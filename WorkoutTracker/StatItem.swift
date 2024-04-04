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

struct StatItem: View {
    @State var expanded = true
    var type: LiftType
    var lifts: [Lift]
    
    @State var position: (Date, Double)? = nil
    
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
    
    var allTimeMax: Double? {
        maxes.values.max()
    }
    
    var body: some View {
        List {
            if let max = allTimeMax {
                Section("Maxes") {
                    Text("All Time Max: \(max.clean) ")
                    Chart {
                        ForEach(maxes.sorted(by: <), id: \.key) { reps, max in
                            BarMark(x: .value("Reps", repToString(reps)), y: .value("Weight", max))
                                .foregroundStyle(by: .value("Reps", repToString(reps)))
                        }
                    }
                }
                
                Section("Progress") {
                    Chart(lifts) { lift in
                        ForEach(lift.maxes().sorted(by: <), id: \.key) { reps, maximum in
                            //                    LineMark(x: .value("Date", lift.timestamp, unit: .day), y: .value(repToString(reps), maximum))
                            //                    .foregroundStyle(by: .value("Reps", repToString(reps)))
                            
                            PointMark(x: .value("Date", lift.timestamp, unit: .day), y: .value(repToString(reps), maximum))
                                .symbol(.circle)
                                .foregroundStyle(by: .value("Reps", repToString(reps)))
                            
                        }
                    }
                    .chartYScale(domain: 0...max * 1.4)
                    .chartScrollableAxes(.horizontal)
                    .chartScrollTargetBehavior(
                        .valueAligned(matching: .init(day: 0))
                    )
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
