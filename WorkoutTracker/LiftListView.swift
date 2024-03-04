//
//  LiftListView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

struct LiftSetView: View {
    var liftSet: LiftSet
    var lift: Lift
    
    var body: some View {
        
        HStack {
                Text(liftSet.reps == 1 ? "**1** rep" : "**\(liftSet.reps)** reps")
                Spacer()
                if lift.weighted {
                    Text(liftSet.weight == 1 ? "**1** pound" : "**\(liftSet.weight.clean)** pounds")
                }
            }
    }
}

struct SetsView: View {
    
    var lift: Lift
    
    var body: some View {
        if lift.sets.isEmpty {
            EmptyView()
        } else {
            HStack {
                if lift.allSetsSame() {
                    Text("\(lift.sets.count)x").font(.title)
                    LiftSetView(liftSet: lift.sets.first!, lift: lift)
                        .font(.title3)
                        .padding()
                        .background(Color(uiColor: UIColor.systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                } else {
                    VStack {
                        ForEach(lift.sets) { liftSet in
                            LiftSetView(liftSet: liftSet, lift: lift)
                            if liftSet.id != lift.sets.last?.id {
                                Divider()
                            }
                        }
                    }
                    .font(.title3)
                    .padding()
                    .background(Color(uiColor: UIColor.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
            }
        }
        
    }
}

struct LiftListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    
    private var liftsByDate: [(TimelessDate, [Lift])] {
        var maybeLastDate : TimelessDate? = nil
        var todayLifts : [Lift] = []
        var output : [(TimelessDate, [Lift])] = []
        
        for lift in lifts{
            let currentDate = lift.timestamp.timeless()
            if let lastDate = maybeLastDate {
                if lastDate != currentDate {
                    output.append((lastDate, todayLifts.sorted(by: {$0.timestamp > $1.timestamp})))
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
            output.append((lastDate, todayLifts.sorted(by: {$0.timestamp > $1.timestamp})))
        }
        return output
    }
    
    
    var body: some View {
        NavigationStack {
            List(liftsByDate, id: \.0.hashValue) { (date, liftsForDate) in
                Section("\(date.format())") {
                    ForEach(liftsForDate) { lift in
                        Menu {
                            NavigationLink(destination: AddLiftView(viewMode: .edit, lift: lift), label: {
                                Text("Edit Lift")
                            })
                        } label: {

                            VStack {
                                HStack {
                                    Text(lift.type.string)
                                        .font(.title)
                                    Spacer()
                                    Text("\(lift.timestamp.formatted(date: .omitted, time: .shortened))")
                                        .font(.caption)
                                    
                                }
                                SetsView(lift: lift)
                            }
                            .padding([.top, .bottom], 5.0)
                            .foregroundStyle(Color.black)
                        }
                    }
                    .onDelete { indexSet in
                        let liftsToRemove = indexSet.map({idx in liftsForDate[idx]})
                        for lift in liftsToRemove {
                            modelContext.delete(lift)
                        }
                    }
                }
            }
            .navigationTitle("Lifts")
            .toolbar() {
                ToolbarItemGroup(placement: .primaryAction, content: {
                    NavigationLink(value: Lift(liftType: .benchPress, timestamp: Date.now), label: {
                        Label("Add Lift", systemImage: "plus")
                   })
                    if lifts.count > 0 {
                        EditButton()
                    }
                })
            }
            .navigationDestination(for: Lift.self) { lift in
                AddLiftView(viewMode: .add, lift: lift).onAppear {
                    modelContext.insert(lift)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)
    lift.addSet(10, weight: 100.0)
    lift.addSet(10, weight: 120.0)
    lift.addSet(10, weight: 130.0)
    
    let secondLift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*10))
    container.mainContext.insert(secondLift)
    secondLift.addSet(10, weight: 250.0)
    secondLift.addSet(10, weight: 250.0)
    secondLift.addSet(10, weight: 250.0)
    
    
    let thirdLift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*60*24 - 10*60))
    container.mainContext.insert(thirdLift)
    thirdLift.addSet(10, weight: 250.0)
    thirdLift.addSet(10, weight: 250.0)
    thirdLift.addSet(10, weight: 250.0)
    

    return LiftListView()
        .modelContainer(container)
}
