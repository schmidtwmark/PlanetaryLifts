//
//  AddLiftView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI

struct AddLiftView: View {
    @State var lift: Lift
    
    
    var body: some View {
        List {
            Section {
                Picker("Type", selection: $lift.type, content: {
                    Text("Bench Press").tag("Bench Press")
                    Text("Back Squat").tag("Back Squat")
                })
                DatePicker(selection: $lift.timestamp, label: {
                    Text("Time")
                })
            }
            Section {
                ForEach(lift.sets) { set in
                    if let weight = set.weight {
                        Text("*\(set.reps)* @ *\(weight)* pounds")
                    } else {
                        Text("*\(set.reps)*")
                    }
                }
            } header: {
                Text("Sets")
            } footer: {
                Button {
                    lift.sets.append(LiftSet(reps: 10, weight: 50))
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Set")
                    }
                }
                .font(.headline)
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }
        }
        .navigationTitle("Add a Lift")
    }
}

#Preview {
    AddLiftView(lift: Lift(type: "Bench Press", sets: [], timestamp: Date.now))
}
