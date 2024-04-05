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
    
    init(lift: Lift) {
        self.mode = .edit(lift)
        self.liftType = lift.type
        self.timestamp = lift.timestamp
        self.isWeighted = lift.weighted
        self.liftSets = lift.sets
        self.modifiers = lift.modifiers
        self.notes = lift.notes
    }
    
    init(liftType: LiftType) {
        self.mode = .add
        self.liftType = liftType
        self.timestamp = Date()
        self.isWeighted = true
        self.liftSets = []
        self.modifiers = Set()
        self.notes = ""
    }
    
    
    enum Mode {
        case add
        case edit(Lift)
    }
    
    @State var mode : Mode
    @State var liftType: LiftType
    @State var timestamp: Date
    @State var isWeighted: Bool
    @State var liftSets: [LiftSet]
    @State var modifiers: Set<LiftModifier>
    @State var notes: String
    
    @Environment(\.modelContext) private var modelContext
    @State var showSetSettings = false
    
    @StateObject var editState: EditState = EditState()
    @Environment(\.dismiss) var dismiss
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    
    var navigationTitle : String {
        return switch mode {
        case .add: "Add Lift"
        case .edit: "Edit Lift"
        }
    }
    
    var enableSave: Bool {
        switch mode {
        case .add:
            return true
        case .edit(let lift):
            return lift.type != liftType 
            || lift.timestamp != timestamp
            || lift.sets != liftSets
            || lift.modifiers != modifiers
            || lift.weighted != isWeighted 
            || lift.notes != notes
        }
    }
    
    @ViewBuilder
    var modifiersSection: some View {
        Section("Modifiers") {
            ForEach(liftType.modifiers, id: \.rawValue) { modifier in
                Label(modifier.rawValue, systemImage: modifiers.contains(modifier) ? "checkmark.circle" : "circle").onTapGesture(perform: {
                    withAnimation {
                        if modifiers.contains(modifier) {
                            modifiers.remove(modifier)
                        } else {
                            let exclusions = modifier.exclusions
                            for exclusion in exclusions {
                                modifiers.remove(exclusion)
                            }
                            modifiers.insert(modifier)
                        }
                    }
                })
            }
        }
    }
    
//    @ViewBuilder
//    var stickersSection: some View {
//        Section("Awards") {
//            ScrollView(.horizontal) {
//                ForEach(stickers, id: \.id) { sticker in
//                    StickerView(config: sticker).scaleEffect(0.2).frame(width: 100, height: 100)
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    var mainSection: some View {
        Section {
            NavigationLink(destination: { LiftTypeSelector(selectedLiftType: $liftType)
            }, label: {
                HStack {
                    Text("Lift Type")
                    Spacer()
                    Text(liftType.string)
                }
            })
            DatePicker(selection: $timestamp, label: {
                Text("Time")
            })
        }
    }
    
    @ViewBuilder
    var setSection: some View {
        Section {
            if showSetSettings {
                Toggle(isOn: $isWeighted.animation(), label: {
                    Text("Weighted Sets")
                })
            }
            ForEach($liftSets) { $liftSet in
                HStack {
                    if editState.setEditMode == .none || editState.setEditMode != .weight(liftSet.id) {
                        NumberPicker(number: $liftSet.reps,
                                     toString: {"\($0)"},
                                     onIncrement: { return $0 + 1},
                                     onDecrement: { return max(1, $0 - 1)},
                                     type: .reps,
                                     id: liftSet.id)
                    }
                    if isWeighted {
                        if editState.setEditMode == .none || editState.setEditMode != .reps(liftSet.id) {
                            if editState.setEditMode != .weight(liftSet.id) {
                                Divider()
                            }
                            NumberPicker(number: $liftSet.weight,
                                         toString: { _ in "\(liftSet.roundedWeight.clean)"},
                                         onIncrement: {return roundedIncrement($0)},
                                         onDecrement: {return max(1.0, roundedDecrement($0))},
                                         type: .weight,
                                         id: liftSet.id)
                        }
                    }
                }
            }.onDelete(perform: { indexSet in
                liftSets.remove(atOffsets: indexSet)
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
                        if editState.setEditMode == .none {
                            if let lastSet = liftSets.last {
                                liftSets.append(LiftSet(reps: lastSet.reps, weight: lastSet.weight, units: lastSet.units))
                            } else {
                                liftSets.append(LiftSet(reps: 10, weight: 50, units: weightUnits))
                            }
                            // TODO: read from global last time this lift was performed

                        } else {
                            editState.setEditMode = .none
                        }
                    }
                } label: {
                    HStack {
                        if editState.setEditMode == .none {
                          Label("Add Set", systemImage: "plus")
                        } else {
                            Label("Done", systemImage: "checkmark")
                        }
                    }
                }
                Spacer()
            }.padding()
        }
    }

    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    mainSection
                    setSection
                    if liftType.modifiers.count > 0 {
                        modifiersSection
                    }
                    Section("Workout Notes") {
                        TextEditor(text: $notes).frame(minHeight: 100)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .environmentObject(editState)
                .navigationTitle(navigationTitle)
                Spacer()
                Button {
                    switch mode {
                    case .add:
                        let newLift = Lift(liftType: liftType, sets: liftSets, timestamp: timestamp, modifiers: modifiers, notes: notes)
                        modelContext.insert(newLift)
                        break
                        
                    case .edit(let lift):
                        print("Updating lift \(lift)")
                        lift.type = liftType
                        lift.sets = liftSets
                        lift.timestamp = timestamp
                        lift.modifiers = modifiers
                        lift.notes = notes
                        print("Updated lift \(lift)")
                        break
                    }
                    
                    dismiss()
                } label: {
                    HStack {
                        Text("Save")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.heavy)
                }
                .disabled(!enableSave)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
            }.background(Color(uiColor: UIColor.systemGroupedBackground))
        }
    }
}

#Preview("Filled Edit") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)
    lift.addSet(10, weight: 100.0, units: .pounds)
    lift.addSet(10, weight: 120.0, units: .pounds)
    lift.addSet(10, weight: 130.0, units: .pounds)
//    lift.addSet(10, weight: 130.0, units: .pounds, sticker: StickerConfig(id: UUID(), timestamp: Date.now, type: .benchPress, reps: 10, weight: 130.0, units: .pounds, colorHex: UIColor.blue.toHex()))

    return NavigationStack {
        AddLiftView(lift: lift)
            .modelContainer(container)
    }
    
}
#Preview("Empty Add") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)
    
    return NavigationStack {
        AddLiftView(liftType: .benchPress)
            .modelContainer(container)
    }
    
}
