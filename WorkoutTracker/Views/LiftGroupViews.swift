//
//  LiftGroupViews.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/12/26.
//

import SwiftUI
import SwiftData

// The lift card shown in group sheets — the same card as the main list.
struct GroupLiftCard: View {
    var lift: Lift
    // When false, the card is display-only (no set edits, add, or delete)
    var interactive: Bool = true
    // Syncs the working copy back after an in-place full edit saves
    var onFullEditSave: (() -> ())? = nil

    @AppStorage(PALETTE) var palette: Palette = .main
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @Query private var allLifts: [Lift]
    @State private var cardState: LiftCardState = .liftInfo
    @State private var setsExpanded: Bool = false

    func addSet() {
        withAnimation {
            lift.addNextSet(history: allLifts, units: weightUnits)
        }
    }

    var body: some View {
        LiftCardView(lift: lift,
                     interactive: interactive,
                     showTimestamp: false,
                     cardState: $cardState,
                     setsExpanded: $setsExpanded,
                     onAddSet: addSet,
                     onFullEditSave: onFullEditSave)
            .tint(lift.type.category.getColor(for: palette))
    }
}

// The editable list of lifts shared by the save-group sheet and the group
// editor: interactive cards, tap-and-hold menu, reorder, and add lift.
struct GroupLiftsList: View {
    @Binding var lifts: [Lift]
    @Binding var name: String
    var onChanged: () -> () = {}

    @Environment(\.modelContext) private var modelContext
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @Query private var allLifts: [Lift]
    @State private var editingLift: Lift? = nil
    @State private var addingLift: Bool = false
    @State private var showStatsForType: LiftType? = nil
    @State private var renaming: Bool = false

    @ViewBuilder
    var renamePopover: some View {
        VStack(spacing: 12.0) {
            Text("Rename Group")
                .font(.headline)
            TextField("Group Name", text: $name)
                .textFieldStyle(.roundedBorder)
            Button {
                renaming = false
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(minWidth: 280.0)
        .presentationCompactAdaptation(.popover)
    }

    func addSet(to lift: Lift) {
        withAnimation {
            lift.addNextSet(history: allLifts, units: weightUnits)
        }
    }

    func removeSet(from lift: Lift) {
        if lift.sets.count > 1 {
            withAnimation {
                _ = lift.sets.removeLast()
            }
        }
    }

    func deleteLift(_ lift: Lift) {
        withAnimation {
            lifts.removeAll(where: {$0 === lift})
        }
        onChanged()
    }

    @ViewBuilder
    var emptyHelp: some View {
        HStack(spacing: 4.0) {
            Spacer()
            Text("Press")
            Button {
                addingLift = true
            } label: {
                Label("Add Lift", systemImage: "plus").labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .clipShape(Capsule())
            Text("to add a lift.")
            Spacer()
        }
        .padding()
    }

    var body: some View {
        List {
            ForEach(lifts) { lift in
                GroupLiftRow(lift: lift, onChanged: onChanged)
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24.0, style: .continuous))
                    .contextMenu {
                        Button {
                            editingLift = lift
                        } label: {
                            Label("Edit Lift", systemImage: "pencil")
                        }
                        Button {
                            addSet(to: lift)
                        } label: {
                            Label("Add Set", systemImage: "plus.circle")
                        }
                        if lift.sets.count > 1 {
                            Button {
                                removeSet(from: lift)
                            } label: {
                                Label("Remove Set", systemImage: "minus.circle")
                            }
                        }
                        Button {
                            showStatsForType = lift.type
                        } label: {
                            Label("Stats", systemImage: "chart.dots.scatter")
                        }
                        Button(role: .destructive) {
                            deleteLift(lift)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6.0, leading: 16.0, bottom: 6.0, trailing: 16.0))
            }
            .onDelete(perform: { indexSet in
                lifts.remove(atOffsets: indexSet)
                onChanged()
            })
            .onMove(perform: { source, destination in
                lifts.move(fromOffsets: source, toOffset: destination)
                onChanged()
            })
        }
        .overlay {
            if lifts.isEmpty {
                emptyHelp
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    renaming = true
                } label: {
                    Label("Rename Group", systemImage: "pencil")
                }
                .popover(isPresented: $renaming) {
                    renamePopover
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addingLift = true
                } label: {
                    Label("Add Lift", systemImage: "plus")
                }
            }
        }
        .sheet(item: $editingLift) { lift in
            AddLiftView(lift: lift, onSave: { _ in onChanged() })
        }
        .sheet(isPresented: $addingLift) {
            AddLiftView(liftType: lifts.last?.type ?? .benchPress, insertOnSave: false, onSave: { lift in
                lifts.append(lift)
                onChanged()
            })
        }
        .sheet(item: $showStatsForType) { type in
            NavigationStack {
                StatItem(type: type, modelContext: modelContext).toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showStatsForType = nil
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
        }
    }
}

struct SaveLiftGroupSheet: View {
    var defaultName: String
    var sourceLifts: [Lift]
    var onSave: (String, [Lift]) -> ()

    // Detached copies so editing here never touches the logged lifts
    @State private var lifts: [Lift] = []
    @State private var loaded: Bool = false
    @State private var name: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if loaded {
                    GroupLiftsList(lifts: $lifts, name: $name)
                } else {
                    Color.clear
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmed.isEmpty ? defaultName : trimmed, lifts)
                        dismiss()
                    } label: {
                        Text("Save Group").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(lifts.isEmpty)
                }
            }
            .onAppear {
                if !loaded {
                    lifts = sourceLifts.map({ LiftGroup.SavedLift(from: $0).makeLift(timestamp: Date.now) })
                    name = defaultName
                    loaded = true
                }
            }
        }
    }
}

// One row of LiftGroupEditView: renders the working copy and syncs
// edits (which all go through lift.sets) back to the group
struct GroupLiftRow: View {
    var lift: Lift
    var onChanged: () -> ()

    var body: some View {
        GroupLiftCard(lift: lift, onFullEditSave: onChanged)
            .onChange(of: lift.sets) {
                onChanged()
            }
    }
}

struct LiftGroupEditView: View {
    @Bindable var group: LiftGroup

    @State private var tempLifts: [Lift] = []
    @State private var loaded: Bool = false

    func syncToGroup() {
        group.lifts = tempLifts.map({LiftGroup.SavedLift(from: $0)})
    }

    var body: some View {
        Group {
            if loaded {
                GroupLiftsList(lifts: $tempLifts, name: $group.name, onChanged: syncToGroup)
            } else {
                Color.clear
            }
        }
        .onAppear {
            if !loaded {
                tempLifts = group.lifts.map({$0.makeLift(timestamp: Date.now)})
                loaded = true
            }
        }
    }
}

#Preview("Edit Group") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, LiftGroup.self, configurations: config)

    let lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline])
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 100.0, units: .pounds))
    let secondLift = Lift(liftType: .backSquat, timestamp: Date.now)
    secondLift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))

    let group = LiftGroup(name: "Push Day", lifts: [lift, secondLift])
    container.mainContext.insert(group)

    return NavigationStack {
        LiftGroupEditView(group: group)
    }
    .modelContainer(container)
}

#Preview("Save Sheet") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, LiftGroup.self, configurations: config)

    let lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline])
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 100.0, units: .pounds))

    return SaveLiftGroupSheet(defaultName: "Saturday July 11th", sourceLifts: [lift], onSave: { _, _ in })
        .modelContainer(container)
}
