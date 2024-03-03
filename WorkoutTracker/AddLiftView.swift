//
//  AddLiftView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

extension Double{
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

struct AddLiftView: View {
    @Bindable var lift: Lift
    @Environment(\.modelContext) private var modelContext
    @State var showSetSettings = false
    
    func getWeights() -> [Double] {
        let small = stride(from: 1.0, to: 12.5, by: 0.5)
        let medium = stride(from: 15, to: 100, by: 2.5)
        let large = stride(from: 100, to: 250, by: 5.0)
        let extraLarge = stride(from: 250, to: 1000, by: 10.0)
        
        
        return Array([small, medium, large, extraLarge].joined())
    }
    
    @State var linkedReps = 0
    @State var linkedWeight = 0.0
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        List {
            Section {
//                Picker("Type", selection: $lift.type, content: {
//                    Text("Bench Press").tag("Bench Press")
//                    Text("Back Squat").tag("Back Squat")
//                })
                NavigationLink(destination: { LiftTypeSelector(selectedLiftType: $lift.type)
                }, label: {
                    HStack {
                        Text("Lift Type")
                        Spacer()
                        Text(lift.type.string)
                    }
                })
                DatePicker(selection: $lift.timestamp, label: {
                    Text("Time")
                })
            }
            Section {
                if showSetSettings {
                    Toggle(isOn: $lift.weighted.animation(), label: {
                        Text("Weighted Sets")
                    })
//                    if lift.weighted {
//                        Toggle(isOn: $lift.equalWeight, label: {
//                            Text("Same Weight Across Sets")
//                        })
//                    }
//                    Toggle(isOn: $lift.equalReps, label: {
//                        Text("Same Repetition Count")
//                    })
                }
                ForEach($lift.sets) { $liftSet in
                    HStack {
                        Picker("", selection: $liftSet.reps) {
                            ForEach(1..<101) { candidate in
                                Text("\(candidate)").tag(candidate)
                            }
                        }
                        Text(liftSet.reps == 1 ? " rep" : " reps")
                        Spacer()
                        if lift.weighted {
                            Picker("", selection: $liftSet.weight) {
                                ForEach(getWeights(), id: \.self) { candidate in
                                    Text("\(candidate.clean)").tag(Optional(candidate))
                                }
                            }
                            Text(liftSet.weight == 1 ? " pound" : " pounds")
                        }
                    }
                }.onDelete(perform: { indexSet in
                    lift.sets.remove(atOffsets: indexSet)
                })
            } header: {
                HStack {
                    Text("Sets")
                    Spacer()
                    Button {
                        withAnimation {
                            showSetSettings.toggle()
                        }
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }.font(.caption)
                }
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        if let lastSet = lift.sets.last {
                            lift.addSet(lastSet.reps, weight: lastSet.weight)
                        } else {
                            lift.addSet(10, weight: 50.0)
                        }
                        // TODO: read from global last time this lift was performed
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Set")
                        }
                    }
                    .font(.headline)
                    .padding(15)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                    Spacer()
                }.padding()
            }
            Section {
                TextEditor(text: $lift.notes)
            } header: {
                Text("Workout Notes")
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                    }
                    .font(.headline)
                    .padding(15)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                    Spacer()
                }.padding()
            }
        }
        .navigationTitle("Add Lift")
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)

    return NavigationStack {
        AddLiftView(lift: lift)
            .modelContainer(container)
    }
    
}
