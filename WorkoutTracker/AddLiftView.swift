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

struct NumberPicker<T: Numeric> : View {
    @Binding var number: T
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    
    var toString: ((T) -> String)
    
    var onIncrement: ((T) -> T)
    var onDecrement: ((T) -> T)
    
    enum NumberType {
        case weight
        case reps
        
        func getSingleUnitString(_ weightUnits: WeightUnits) -> String {
            return switch self {
            case .weight: weightUnits.singleUnit
            case .reps: "rep"
            }
        }
    }
    
    var type: NumberType
    var id: UUID
    
    var selected : Bool {
        switch type {
        case .weight: editState.setEditMode == .weight(id)
        case .reps: editState.setEditMode == .reps(id)
        }
    }
    
    var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            if type == .weight {
                formatter.numberStyle = .decimal
            }
            return formatter
    }
    
    var keyboardType: UIKeyboardType {
        return switch type {
            case .weight: .decimalPad
            case .reps: .numberPad
        }
    }
    
    @EnvironmentObject var editState: EditState
    var body: some View {
        HStack {
            if selected {
                Button {
                    withAnimation {
                        editState.setEditMode = .none
                    }
                } label: {
                    Label("Done", systemImage: "checkmark").labelStyle(.iconOnly)
                }
            }
            
            Group {
                Spacer()
                if selected {
                    HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                        TextField("", value: $number, formatter: formatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
                            .fontWeight(.bold)
                            .background(Color(uiColor: UIColor.secondarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        Text("\(type.getSingleUnitString(weightUnits))\(number != 1 ? "s" : "")")
                    }
                    .padding(EdgeInsets(top: 0.0, leading: 10.0, bottom: 0.0, trailing: 30.0))
                } else {
                    Group {
                        Text("\(toString(number))")
                            .fontWeight(.bold)
                        Text("\(type.getSingleUnitString(weightUnits))\(number != 1 ? "s" : "")")
                    }
                    .onTapGesture {
                        withAnimation {
                            editState.setEditMode = switch type {
                            case .weight: .weight(id)
                            case .reps: .reps(id)
                            }
                        }
                    }
                }
                Spacer()
            }
            
            if selected {
                Stepper("", onIncrement: {
                    number = onIncrement(number)
                }, onDecrement: {
                    number = onDecrement(number)
                })
                .labelsHidden()
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return 0
        }
    }
}

class EditState : ObservableObject {
    enum SetEditMode : Equatable {
        case none
        case reps(UUID)
        case weight(UUID)
    }
    
    @Published var setEditMode: SetEditMode = .none
   
}

func weightGranularityIncrement(_ current: Double) -> Double {
    return if current < 12.5 {
        0.5
    } else if current < 100.0 {
        2.5
    } else if current < 250.0 {
        5.0
    } else {
        10.0
    }
}

func weightGranularityDecrement(_ current: Double) -> Double {
    return if current <= 12.5 {
        0.5
    } else if current <= 100.0 {
        2.5
    } else if current <= 250.0 {
        5.0
    } else {
        10.0
    }
    
}

func roundGranularIncrement(_ current: Double) -> Double {
    let granularity = weightGranularityIncrement(current)
    return round(current / granularity) * granularity
}

func roundedIncrement(_ current: Double) -> Double {
    let granularity = weightGranularityIncrement(current)
    return roundGranularIncrement(current + granularity)
}
func roundGranularDecrement(_ current: Double) -> Double {
    let granularity = weightGranularityDecrement(current)
    return round(current / granularity) * granularity
}


func roundedDecrement(_ current: Double) -> Double {
    let granularity = weightGranularityDecrement(current)
    return roundGranularDecrement(current - granularity)
}


struct AddLiftView: View {
    enum ViewMode {
        case add
        case edit
    }
    
    let viewMode : ViewMode
    
    @State var lift: Lift
    @Environment(\.modelContext) private var modelContext
    @State var showSetSettings = false
    
    
    
    @StateObject var editState: EditState = EditState()
    
    
    var weights: [Double] {
        let small = stride(from: 1.0, to: 12.5, by: 0.5)
        let medium = stride(from: 15, to: 100, by: 2.5)
        let large = stride(from: 100, to: 250, by: 5.0)
        let extraLarge = stride(from: 250, to: 1000, by: 10.0)
        
        
        return Array([small, medium, large, extraLarge].joined())
    }
    
    @State var linkedReps = 0
    @State var linkedWeight = 0.0
    @Environment(\.dismiss) var dismiss
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    
    var navigationTitle : String {
        return switch viewMode {
        case .add: "Add Lift"
        case .edit: "Edit Lift"
        }
    }

    
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
                            if editState.setEditMode == .none || editState.setEditMode != .weight(liftSet.id) {
                                NumberPicker(number: $liftSet.reps, 
                                             toString: {"\($0)"},
                                             onIncrement: { return $0 + 1},
                                             onDecrement: { return max(1, $0 - 1)},
                                             type: .reps,
                                             id: liftSet.id)
                            }
                            if lift.weighted {
                                if editState.setEditMode == .none || editState.setEditMode != .reps(liftSet.id) {
                                    if editState.setEditMode != .weight(liftSet.id) {
                                        Divider()
                                    }
                                    NumberPicker(number: $liftSet.weight.weight,
                                                 toString: { _ in "\(liftSet.weight.weight.clean)"},
                                                 onIncrement: {return roundedIncrement($0)},
                                                 onDecrement: {return max(1.0, roundedDecrement($0))},
                                                 type: .weight,
                                                 id: liftSet.id)
                                }
                            }
                        }
//                        .listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 10.0))
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
                        withAnimation {
                            editState.setEditMode = .none
                            if let lastSet = lift.sets.last {
                                lift.addSet(lastSet.reps, weight: lastSet.weight)
                            } else {
                                lift.addSet(10, weight: Weight(weight: 50.0, units: weightUnits))
                            }
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
                TextEditor(text: $lift.notes).frame(minHeight: 100)
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
        .environmentObject(editState)
        .navigationTitle(navigationTitle)
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)

    return NavigationStack {
        AddLiftView(viewMode: .add, lift: lift)
            .modelContainer(container)
    }
    
}
