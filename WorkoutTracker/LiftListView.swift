//
//  LiftListView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

struct LiftListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var lifts: [Lift]
    
    private var liftsByDate: [(TimelessDate, [Lift])] {
        var maybeLastDate : TimelessDate? = nil
        var todayLifts : [Lift] = []
        var output : [(TimelessDate, [Lift])] = []
        
        for lift in lifts{
            let currentDate = lift.timestamp.timeless()
            if let lastDate = maybeLastDate {
                if lastDate != currentDate {
                    output.append((lastDate, todayLifts.sorted(by: {$0.timestamp < $1.timestamp})))
                    maybeLastDate = currentDate
                    todayLifts = []
                }
            } else {
                maybeLastDate = currentDate
            }
            todayLifts.append(lift)
            
        }
        
        // Clear out the last chunk
        if let lastDate = maybeLastDate {
            output.append((lastDate, todayLifts.sorted(by: {$0.timestamp < $1.timestamp})))
        }
        return output
    }
    
    
    var body: some View {
        NavigationStack {
            List(liftsByDate, id: \.0.hashValue) { (date, lifts) in
                Section("\(date.format())") {
                    ForEach(lifts) { lift in
                        VStack {
                            HStack {
                                Text(lift.type)
                                Spacer()
                                Text("\(lift.timestamp.formatted(date: .omitted, time: .shortened))")
                            }
                            ForEach(lift.orderedSets) { liftSet in
                                if lift.weighted {
                                    if liftSet.weight == 1 {
                                        Text("\(liftSet.reps) reps at 1 pound")
                                    } else {
                                        Text("\(liftSet.reps) reps at \(liftSet.weight!.clean) pounds")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lifts")
            .toolbar() {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink(value: Lift(type: "Bench Press", sets: [], timestamp: Date.now), label: {
                        Label("Add Lift", systemImage: "plus")
                    })
                })
            }
            .navigationDestination(for: Lift.self) { lift in
                AddLiftView(lift: lift).onAppear {
                    modelContext.insert(lift)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, LiftSet.self, configurations: config)
    
    let lift = Lift(type: "Bench Press", sets: [], timestamp: Date.now)
    container.mainContext.insert(lift)
    lift.addSet(10, weight: 100.0)

    return LiftListView()
        .modelContainer(container)
}
