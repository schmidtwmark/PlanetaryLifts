//
//  AddLiftView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData


class EditState : ObservableObject {
    enum SetEditMode : Equatable {
        case none
        case reps(UUID)
        case weight(UUID)
        
        var editingId: UUID? {
            switch self {
            case .none:
                nil
            case .reps(let UUID):
                UUID
            case .weight(let UUID):
                UUID
            }
        }
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

struct AddLiftMuscleGroupView: View {
    @State var selector: LiftListItemMuscleGroupSelector
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    var lift: Lift
    var body: some View {
        LiftMuscleGroupSilhouetteView(selector: $selector, lift: lift)
        
        if let selected = selector.selectedMuscleGroup {
            HStack {
                Text(selected.rawValue)
                Spacer()
                Text(weightDisplayString(selector.getWeight(selected, userGeneratedTypes: userGeneratedTypes)))
            }
        }
    }
    
    init(lift: Lift) {
        selector = .init(lift: lift)
        self.lift = lift
    }

}


struct AddLiftView: View {
    
    // Edit
    init(lift: Lift, onSave: @escaping (Lift) -> ()) {
        self.mode = .edit(lift)
        self.liftType = lift.type
        self.timestamp = lift.timestamp
        self.isWeighted = lift.weighted
        self.liftSets = lift.sets
        self.modifiers = lift.modifiers
        self.notes = lift.notes
        self.onSave = onSave
    }
    
    // Add
    init(liftType: LiftType, updateUnreadLifts: Bool = false, onSave: @escaping (Lift) -> ()) {
        self.mode = .add
        self.liftType = liftType
        self.timestamp = Date()
        self.isWeighted = true
        self.liftSets = []
        self.modifiers = Set()
        self.notes = ""
        self.updateUnreadLifts = updateUnreadLifts
        self.onSave = onSave
    }
    
    
    enum Mode {
        case add
        case edit(Lift)
    }
    
    
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    @State var mode : Mode
    @State var liftType: LiftType
    @State var timestamp: Date
    @State var isWeighted: Bool
    @State var liftSets: [LiftSet]
    @State var modifiers: Set<LiftModifier>
    @State var notes: String
    var updateUnreadLifts = false
    var onSave: (Lift) -> ()
    
    @Environment(\.modelContext) private var modelContext
    @State var showSetSettings = false
    @State var showMuscleGroups = false
    
    @StateObject var editState: EditState = EditState()
    @Environment(\.dismiss) var dismiss
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @AppStorage(PALETTE) var palette: Palette = .main
    @AppStorage(UNREAD_LIFTS) var unreadLifts: Int = 0
    
    var mostRecentLift: Lift? {
        lifts.first(where: {$0.type == liftType})
    }
    
    var mostRecentSet: LiftSet? {
        mostRecentLift?.sets.first
    }
    
    var navigationTitle : String {
        return switch mode {
        case .add: "Add Lift"
        case .edit: "Edit Lift"
        }
    }
    
    var enableSave: Bool {
        let differs = switch mode {
        case .add:
           true
        case .edit(let lift):
            lift.type != liftType
            || lift.timestamp != timestamp
            || lift.sets != liftSets
            || lift.modifiers != modifiers
            || lift.weighted != isWeighted 
            || lift.notes != notes
        }
        return differs || editState.setEditMode != .none
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
    
    
    var baseBarWeight: Double {
        switch weightUnits {
        case .pounds: 45.0
        case .kilograms: 20.4
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
            NavigationLink(destination: { LiftTypeSelector(selectedLiftType: $liftType, modelContext: modelContext)
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
    func weightEditModeSelector(weightEditingId: UUID) -> some View {
        let index = liftSets.firstIndex(where: { $0.id == weightEditingId} )!
        var liftSet = liftSets[index]
        Picker("", selection: Binding(get: {
            switch liftSet.weight.data {
            case .rawWeight(_):
                return Weight.WeightDataTypes.rawWeight
            case .plates(_):
                return Weight.WeightDataTypes.plates
            }
        }, set: {
            switch $0 {
            case Weight.WeightDataTypes.rawWeight:
                print("Setting to raw weight")
                liftSet.weight.data = .rawWeight(liftSet.weight.weight)
            case Weight.WeightDataTypes.plates:
                print("Setting to plates")
                liftSet.weight.data = .plates(WeightPlates(barWeight: baseBarWeight, plates: []))
                print("After: \(liftSet.weight.data)")
            }
            liftSets[index] = liftSet
        })) {
            Text("Exact Weight").tag(Weight.WeightDataTypes.rawWeight)
            Text("Plates").tag(Weight.WeightDataTypes.plates)
        }.pickerStyle(.segmented)
    }
    
    @ViewBuilder
    var setSection: some View {
        Section {
            if showSetSettings {
                Toggle(isOn: $isWeighted.animation(), label: {
                    Text("Weighted Sets")
                })
            }
            ForEach($liftSets, id: \.id) { $liftSet in
                if case .weight(let weightEditingId) = editState.setEditMode, liftSet.id == weightEditingId {
                    weightEditModeSelector(weightEditingId: weightEditingId)
                }
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
                            switch liftSet.weight.data {
                            case .rawWeight(let rawWeight):
                                NumberPicker(number: Binding(get: {
                                    return rawWeight
                                }, set: { liftSet.weight.data = .rawWeight($0)}),
                                             toString: { _ in "\(liftSet.weight.roundedWeight.clean)"},
                                             onIncrement: {return roundedIncrement($0)},
                                             onDecrement: {return max(1.0, roundedDecrement($0))},
                                             type: .weight,
                                             id: liftSet.id)
                                
                            case .plates(let plates):
                                HStack {
                                    Group {
                                        if editState.setEditMode == .weight(liftSet.id) {
                                            PlatesEditorView(plates: Binding(get: {
                                                return plates
                                            }, set: {
                                                liftSet.weight.data = .plates($0)
                                            }), removePlate: { removeId in
                                                if case .plates(var editablePlates) = liftSet.weight.data {
                                                    editablePlates.plates.removeAll(where: {$0.id == removeId})
                                                    liftSet.weight.data = .plates(editablePlates)
                                                }
                                                
                                            }, addPlate: { plateWeight in
                                                if case .plates(var editablePlates) = liftSet.weight.data {
                                                    editablePlates.plates.append(WeightPlates.Plate(weight: plateWeight))
                                                    editablePlates.plates.sort(by: >)
                                                    liftSet.weight.data = .plates(editablePlates)
                                                }

                                            },
                                            accentColor: liftType.category.getColor(for: palette),
                                            units: liftSet.weight.units)
                                        } else {
                                            Spacer()
                                            Text(try! AttributedString(markdown: "\(liftSet.weight.shortDisplayString)"))
                                                .onTapGesture {
                                                    withAnimation {
                                                        editState.setEditMode = .weight(liftSet.id)
                                                    }
                                                }
                                            Spacer()
                                        }
                                    }
                                }
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    return 0
                                }

                                
                            }
                        }
                    }
                }
            }.onDelete(perform: { indexSet in
                for index in indexSet {
                    let liftSet = liftSets[index]
                    if let editId = editState.setEditMode.editingId, editId == liftSet.id {
                        editState.setEditMode = .none
                    }
                }
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
                }.font(.subheadline.smallCaps())
            }
        } footer: {
            HStack {
                Spacer()
                if editState.setEditMode == .none {
                    Button {
                        withAnimation {
                            if let lastSet = liftSets.last {
                                liftSets.append(lastSet.clone())
                            } else if let mostRecentLift = mostRecentLift, let mostRecentSet = mostRecentSet {
                                if isWeighted && !mostRecentLift.weighted {
                                    isWeighted = false
                                }
                                liftSets.append(mostRecentSet.clone())
                            } else {
                                liftSets.append(LiftSet(reps: 10, weight: 50, units: weightUnits))
                            }
                        }
                    } label: {
                        HStack {
                            Label("Add Set", systemImage: "plus")
                        }
                    }
                }
                Spacer()
            }.padding()
        }
    }
    
    func liftFromEdits() -> Lift {
        return Lift(liftType: liftType, sets: liftSets, timestamp: timestamp, modifiers: modifiers, notes: notes, weighted: isWeighted)
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    mainSection
                    if showMuscleGroups {
                       AddLiftMuscleGroupView(lift: liftFromEdits())
                    }
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
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation {
                                showMuscleGroups.toggle()
                            }
                        } label: {
                            Label("Show/Hide Muscle Groups", systemImage: showMuscleGroups ? "figure.child.circle.fill" : "figure.child.circle").labelStyle(.iconOnly)
                        }
                    }
                }
                .environmentObject(editState)
                .navigationTitle(navigationTitle)
                Spacer()
                HStack {
                    Button {
                        withAnimation {
                            if editState.setEditMode == .none {
                                switch mode {
                                case .add:
                                    let lift = liftFromEdits()
                                    modelContext.insert(lift)
                                    onSave(lift)
                                    break
                                    
                                case .edit(let lift):
                                    print("Updating lift \(lift)")
                                    lift.type = liftType
                                    lift.sets = liftSets
                                    lift.timestamp = timestamp
                                    lift.modifiers = modifiers
                                    lift.notes = notes
                                    lift.weighted = isWeighted
                                    print("Updated lift \(lift)")
                                    onSave(lift)
                                    break
                                }
                                if updateUnreadLifts {
                                    unreadLifts += 1
                                }
                                dismiss()
                            } else {
                                editState.setEditMode = .none
                            }
                        }
                    } label: {
                        HStack {
                            Text(editState.setEditMode == .none ? "Save" : "Save Set")
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                    }
                    .disabled(!enableSave)
                    .buttonStyle(.borderedProminent)
                    if let editingId = editState.setEditMode.editingId,
                        let editingSet = liftSets.first(where: {$0.id == editingId}), showUpdateAllSetsButton(editingSet: editingSet) {
                        Button {
                            withAnimation {
                                liftSets = liftSets.map({
                                    var copy = $0
                                    switch editState.setEditMode {
                                    case .none:
                                        break
                                    case .reps(_):
                                        copy.reps = editingSet.reps
                                    case .weight(_):
                                        copy.weight = editingSet.weight.clone()
                                        
                                    }
                                    return copy

                                })
                                editState.setEditMode = .none
                            }

                        } label: {
                            HStack {
                                Text("Update All Sets")
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20.0)
                .padding(.bottom, UIApplication.shared.bottomSafeAreaInset <= 20.0 ? 20.0 : 0.0)
            }
            .tint(liftType.category.getColor(for: palette))
            .background(Color(uiColor: UIColor.systemGroupedBackground))
        }
    }
    
    private func showUpdateAllSetsButton(editingSet: LiftSet) -> Bool {
        let anyDifferent = switch editState.setEditMode {
        case .none:
            false
        case .reps(_):
            liftSets.contains(where: {$0.reps != editingSet.reps})
        case .weight(_):
            liftSets.contains(where: { !editingSet.weight.same(other: $0.weight)})
        }
        
        return anyDifferent && liftSets.count > 1
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

    return NavigationStack {
        AddLiftView(lift: lift, onSave: { _ in })
            .modelContainer(container)
    }
    
}

#Preview("Plates Edit") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    container.mainContext.insert(lift)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)

    return NavigationStack {
        AddLiftView(lift: lift, onSave: { _ in })
            .modelContainer(container)
    }
    
}
#Preview("Empty Add") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    container.mainContext.insert(lift)
    
    return NavigationStack {
        AddLiftView(liftType: .benchPress, onSave: { _ in })
            .modelContainer(container)
    }
    
}
