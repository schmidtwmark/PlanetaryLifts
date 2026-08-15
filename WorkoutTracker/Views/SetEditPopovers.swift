//
//  SetEditPopovers.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 7/12/26.
//

import SwiftUI
import SwiftData

let repsFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.zeroSymbol = "0"
    return formatter
}()

let weightFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.zeroSymbol = "0"
    return formatter
}()

// A tappable summary of historic sets: a single all-time max, or a recent
// lift's full set configuration (with plate setups preserved)
struct SetChip: Identifiable, Equatable {
    var label: String
    var sets: [LiftSet]

    var isPlates: Bool {
        sets.contains(where: {
            if case .plates(_) = $0.weight.data {
                return true
            }
            return false
        })
    }

    var id: String {
        label + (isPlates ? " •plates" : "")
    }
}

func setChipLabel(_ sets: [LiftSet], units: WeightUnits) -> String {
    guard let first = sets.first else {
        return ""
    }
    let unitSuffix = "\(units.shortSingleUnit)s"
    let allSame = sets.allSatisfy({ $0.reps == first.reps && $0.weight.roundedWeight == first.weight.roundedWeight })
    if allSame {
        if sets.count == 1 {
            return "\(first.reps) rep\(first.reps == 1 ? "" : "s") @ \(first.weight.roundedWeight.clean) \(unitSuffix)"
        }
        return "\(sets.count)x\(first.reps) @ \(first.weight.roundedWeight.clean) \(unitSuffix)"
    }
    return sets.map({ "\($0.reps)@\($0.weight.roundedWeight.clean)" }).joined(separator: ", ") + " " + unitSuffix
}

// Aggregates every set ever logged for the type into per-rep-count maxes,
// then keeps only the undominated ones (dropping any rep count whose max
// weight is matched or beaten at a higher rep count)
func computeMaxChips(liftType: LiftType, lifts: [Lift], units: WeightUnits) -> [SetChip] {
    var bestByReps: [Int: Weight] = [:]
    for lift in lifts where lift.type == liftType && lift.weighted {
        for liftSet in lift.sets {
            let converted = liftSet.convert(to: units)
            let weight = converted.weight.roundedWeight
            if weight <= 0.0 {
                continue
            }
            if let best = bestByReps[liftSet.reps], best.roundedWeight >= weight {
                continue
            }
            bestByReps[liftSet.reps] = converted.weight
        }
    }

    var chips: [SetChip] = []
    var runningMax = 0.0
    for reps in bestByReps.keys.sorted(by: >) {
        let weight = bestByReps[reps]!
        if weight.roundedWeight > runningMax {
            let liftSet = LiftSet(reps: reps, weight: weight)
            chips.append(SetChip(label: setChipLabel([liftSet], units: units), sets: [liftSet]))
            runningMax = weight.roundedWeight
        }
    }
    return chips
}

// The most recent distinct set configurations logged for the type, oldest
// first so the newest ends up at the trailing edge
func computeRecentChips(liftType: LiftType, lifts: [Lift], units: WeightUnits, excluding: Lift? = nil, limit: Int = 5) -> [SetChip] {
    var chips: [SetChip] = []
    var seen = Set<String>()
    let history = lifts
        .filter({ $0.type == liftType && $0.weighted && !$0.sets.isEmpty && $0 !== excluding })
        .sorted(by: { $0.timestamp > $1.timestamp })
    for lift in history {
        let sets = lift.sets.map({ $0.convert(to: units) })
        if sets.contains(where: { $0.weight.roundedWeight <= 0.0 }) {
            continue
        }
        let chip = SetChip(label: setChipLabel(sets, units: units), sets: sets)
        if seen.contains(chip.id) {
            continue
        }
        seen.insert(chip.id)
        chips.append(chip)
        if chips.count >= limit {
            break
        }
    }
    return chips.reversed()
}

// A labeled, horizontally scrolling, trailing-aligned row of set chips.
// Chips fade out as they approach the label on the leading side and clip at
// the true edge of the list inset on the trailing side.
struct SetChipsRow: View {
    var label: String
    var chips: [SetChip]
    var accent: Color
    var onSelect: (SetChip) -> ()
    var edgeExtension: CGFloat = 20.0

    @Environment(\.colorScheme) private var colorScheme
    @State private var labelWidth: CGFloat = 52.0

    var chipTextColor: Color {
        switch colorScheme {
        case .light:
            Color.black
        case .dark:
            Color.white
        @unknown default:
            Color.white
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.0) {
                    ForEach(chips) { chip in
                        Button {
                            onSelect(chip)
                        } label: {
                            HStack(spacing: 4.0) {
                                Text(chip.label)
                                if chip.isPlates {
                                    Image(systemName: "dumbbell")
                                        .imageScale(.small)
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(chipTextColor)
                            .padding(.horizontal, 10.0)
                            .padding(.vertical, 6.0)
                            .background(accent)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.leading, labelWidth + 12.0)
                .padding(.trailing, edgeExtension)
            }
            .defaultScrollAnchor(.trailing)
            .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
            // Dissolve chips as they near the label instead of hard-clipping
            .mask(
                HStack(spacing: 0.0) {
                    Color.clear.frame(width: max(0.0, labelWidth - 8.0))
                    LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 48.0)
                    Color.black
                }
            )
            .padding(.trailing, -edgeExtension)

            Text(label)
                .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: { labelWidth = $0 })
        }
    }
}

// Both history rows (maxes and recents) stacked, for the set edit sheet
struct LiftHistoryChips: View {
    var liftType: LiftType
    var accent: Color
    var excluding: Lift? = nil
    var onSelectMax: (SetChip) -> ()
    var onSelectRecent: (SetChip) -> ()

    @Query var lifts: [Lift]
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds

    var body: some View {
        let maxChips = computeMaxChips(liftType: liftType, lifts: lifts, units: weightUnits)
        let recentChips = computeRecentChips(liftType: liftType, lifts: lifts, units: weightUnits, excluding: excluding)
        if !maxChips.isEmpty || !recentChips.isEmpty {
            VStack(spacing: 10.0) {
                if !maxChips.isEmpty {
                    SetChipsRow(label: maxChips.count == 1 ? "Max" : "Maxes", chips: maxChips, accent: accent, onSelect: onSelectMax)
                }
                if !recentChips.isEmpty {
                    SetChipsRow(label: "Recent", chips: recentChips, accent: accent, onSelect: onSelectRecent)
                }
            }
        }
    }
}

// The primary/secondary update buttons shared by the edit sheets, matching the
// save bar on the edit lift screen: a full-width prominent button with an
// optional secondary button to its right.
struct SheetUpdateButtons: View {
    var showAllSets: Bool
    var enabled: Bool
    var onUpdateSet: () -> ()
    var onUpdateAll: () -> ()

    @ViewBuilder
    var updateSetButton: some View {
        let button = Button {
            onUpdateSet()
        } label: {
            Text("Update Set")
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(10)
                .frame(maxWidth: .infinity)
        }
        .disabled(!enabled)

        if #available(iOS 26, *) {
            button.buttonStyle(.glassProminent)
        } else {
            button.buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    var updateAllSetsButton: some View {
        let button = Button {
            onUpdateAll()
        } label: {
            Text("Update All Sets")
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(10)
                .frame(maxWidth: .infinity)
        }
        .disabled(!enabled)

        if #available(iOS 26, *) {
            button.buttonStyle(.glass)
        } else {
            button.buttonStyle(.bordered)
        }
    }

    var body: some View {
        HStack {
            updateSetButton
            if showAllSets {
                updateAllSetsButton
            }
        }
    }
}

// Reveals a trailing delete button when the content is dragged left, with the
// rubber-band overscroll and full-swipe-to-delete of a normal list row. The
// in-flight drag lives in @GestureState, which SwiftUI resets even when the
// gesture is cancelled (e.g. a tap that opens a sheet mid-drag), so the row
// can never get stuck partially shifted.
struct SwipeToDeleteRow<Content: View>: View {
    var enabled: Bool
    var onDelete: () -> ()
    @ViewBuilder var content: Content

    // The only persistent positions: 0 (closed) or -deleteWidth (revealed)
    @State private var settledOffset: CGFloat = 0
    @GestureState private var dragTranslation: CGFloat = 0
    @State private var rowWidth: CGFloat = 0
    private let deleteWidth: CGFloat = 72.0

    // Diminishing-returns resistance, matching UIScrollView's rubber banding.
    private func rubberBand(_ distance: CGFloat, dimension: CGFloat) -> CGFloat {
        let dim = dimension > 0 ? dimension : 320.0
        let c: CGFloat = 0.55
        return (1 - (1 / (distance * c / dim + 1))) * dim
    }

    private func clamped(_ raw: CGFloat) -> CGFloat {
        if raw < -deleteWidth {
            return -deleteWidth - rubberBand(-deleteWidth - raw, dimension: rowWidth)
        } else if raw > 0 {
            return rubberBand(raw, dimension: rowWidth)
        }
        return raw
    }

    private var offset: CGFloat {
        clamped(settledOffset + dragTranslation)
    }

    var body: some View {
        if !enabled {
            content
        } else {
            ZStack(alignment: .trailing) {
                Button(role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        settledOffset = 0
                        onDelete()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(maxHeight: .infinity)
                        .frame(width: max(deleteWidth, -offset))
                }
                .buttonStyle(.plain)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                .opacity(offset < 0 ? 1 : 0)

                content
                    .overlay {
                        // Tapping a row with the delete revealed closes it,
                        // like a standard list row
                        if settledOffset < 0 {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        settledOffset = 0
                                    }
                                }
                        }
                    }
                    .offset(x: offset)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { rowWidth = proxy.size.width }
                                .onChange(of: proxy.size.width) { _, w in rowWidth = w }
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 16)
                            .updating($dragTranslation) { value, state, _ in
                                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                                state = value.translation.width
                            }
                            .onEnded { value in
                                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                                let end = clamped(settledOffset + value.translation.width)
                                if rowWidth > 0 && -end > rowWidth * 0.5 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        settledOffset = 0
                                        onDelete()
                                    }
                                    return
                                }
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    settledOffset = end < -deleteWidth / 2 ? -deleteWidth : 0
                                }
                            }
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dragTranslation == 0)
            }
        }
    }
}

struct RepsEditPopover: View {
    var lift: Lift
    var setId: UUID

    @Environment(\.dismiss) var dismiss
    @State var reps: Int
    let originalReps: Int

    init(lift: Lift, setId: UUID) {
        self.lift = lift
        self.setId = setId
        let current = lift.sets.first(where: {$0.id == setId})?.reps ?? 10
        originalReps = current
        _reps = State(initialValue: current)
    }

    var edited: Bool {
        reps != originalReps
    }

    var body: some View {
        VStack(spacing: 20.0) {
            HStack(alignment: .firstTextBaseline, spacing: 8.0) {
                NumberIncrementor(number: $reps,
                                  toString: {"\($0)"},
                                  onIncrement: { $0 + 1 },
                                  onDecrement: { max(1, $0 - 1) },
                                  formatter: repsFormatter)
                Text(reps == 1 ? "rep" : "reps")
            }
            SheetUpdateButtons(showAllSets: lift.sets.count > 1, enabled: edited,
                onUpdateSet: {
                    if let index = lift.sets.firstIndex(where: {$0.id == setId}) {
                        lift.sets[index].reps = reps
                    }
                    dismiss()
                },
                onUpdateAll: {
                    lift.sets = lift.sets.map({
                        var copy = $0
                        copy.reps = reps
                        return copy
                    })
                    dismiss()
                })
        }
        .padding(.horizontal, 20.0)
        .padding(.top, 12.0)
        .padding(.bottom, 4.0)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }
}

struct WeightEditPopover: View {
    var lift: Lift
    var setId: UUID

    @Environment(\.dismiss) var dismiss
    @AppStorage(PALETTE) var palette: Palette = .main
    @State var weight: Weight
    // Set when a max chip is tapped, so its reps apply alongside the weight
    @State var pendingReps: Int? = nil
    let originalWeight: Weight
    let originalReps: Int

    init(lift: Lift, setId: UUID) {
        self.lift = lift
        self.setId = setId
        let currentSet = lift.sets.first(where: {$0.id == setId})
        let current = currentSet?.weight ?? Weight(data: .rawWeight(50.0), units: .pounds)
        originalWeight = current
        originalReps = currentSet?.reps ?? 10
        _weight = State(initialValue: current.clone())
    }

    var edited: Bool {
        if !weight.same(other: originalWeight) {
            return true
        }
        if let pendingReps = pendingReps, pendingReps != originalReps {
            return true
        }
        return false
    }

    func apply(to liftSet: inout LiftSet) {
        liftSet.weight = weight.clone()
        if let pendingReps = pendingReps {
            liftSet.reps = pendingReps
        }
    }

    // Stages a chip's leading set as this set's new weight and reps
    func stage(_ chip: SetChip) {
        guard let first = chip.sets.first else {
            return
        }
        withAnimation {
            weight = first.weight.clone()
            pendingReps = first.reps
        }
    }

    var baseBarWeight: Double {
        switch weight.units {
        case .pounds: 45.0
        case .kilograms: 20.4
        }
    }

    var body: some View {
        VStack(spacing: 20.0) {
            LiftHistoryChips(liftType: lift.type,
                             accent: lift.type.category.getColor(for: palette),
                             excluding: lift,
                             onSelectMax: { stage($0) },
                             onSelectRecent: { stage($0) })
            VStack(spacing: 12.0) {
            Picker("", selection: Binding(get: {
                switch weight.data {
                case .rawWeight(_):
                    return Weight.WeightDataTypes.rawWeight
                case .plates(_):
                    return Weight.WeightDataTypes.plates
                }
            }, set: {
                switch $0 {
                case Weight.WeightDataTypes.rawWeight:
                    weight.data = .rawWeight(weight.weight)
                case Weight.WeightDataTypes.plates:
                    weight.data = .plates(WeightPlates(barWeight: baseBarWeight, plates: []))
                }
            })) {
                Text("Exact Weight").tag(Weight.WeightDataTypes.rawWeight)
                Text("Plates").tag(Weight.WeightDataTypes.plates)
            }.pickerStyle(.segmented)

            switch weight.data {
            case .rawWeight(let rawWeight):
                HStack(alignment: .firstTextBaseline, spacing: 8.0) {
                    NumberIncrementor(number: Binding(get: {
                        return rawWeight
                    }, set: { weight.data = .rawWeight($0) }),
                                      toString: { _ in "\(weight.roundedWeight.clean)"},
                                      onIncrement: { return roundedIncrement($0) },
                                      onDecrement: { return roundedDecrement($0) },
                                      formatter: weightFormatter)
                    Text("\(weight.units.singleUnit)s")
                }
            case .plates(let plates):
                PlatesEditorView(plates: Binding(get: {
                    return plates
                }, set: {
                    weight.data = .plates($0)
                }), removePlate: { removeId in
                    if case .plates(var editablePlates) = weight.data {
                        editablePlates.plates.removeAll(where: {$0.id == removeId})
                        weight.data = .plates(editablePlates)
                    }
                }, addPlate: { plateWeight in
                    if case .plates(var editablePlates) = weight.data {
                        editablePlates.plates.append(WeightPlates.Plate(weight: plateWeight))
                        editablePlates.plates.sort(by: >)
                        weight.data = .plates(editablePlates)
                    }
                },
                                 accentColor: lift.type.category.getColor(for: palette),
                                 units: weight.units)
            }
            }

            SheetUpdateButtons(showAllSets: lift.sets.count > 1, enabled: edited,
                onUpdateSet: {
                    if let index = lift.sets.firstIndex(where: {$0.id == setId}) {
                        apply(to: &lift.sets[index])
                    }
                    dismiss()
                },
                onUpdateAll: {
                    lift.sets = lift.sets.map({
                        var copy = $0
                        apply(to: &copy)
                        return copy
                    })
                    dismiss()
                })
        }
        .padding(.horizontal, 20.0)
        .padding(.top, 12.0)
        .padding(.bottom, 4.0)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }
}

// Presents a set's reps/weight editor as a fitted bottom sheet that can be
// dragged (or expanded via the toolbar button) up to the full Edit Lift editor.
struct SetEditSheet: View {
    enum Mode {
        case reps
        case weight
    }

    var lift: Lift
    var setId: UUID
    var mode: Mode
    var accentColor: Color
    var onFullEditSave: () -> ()

    @Environment(\.dismiss) private var dismiss
    @State private var expanded: Bool = false
    @State private var compactHeight: CGFloat = 300.0

    // Room for the sheet's large-title navigation bar above the content
    private let navBarAllowance: CGFloat = 100.0

    private var compactDetent: PresentationDetent {
        .height(compactHeight + navBarAllowance)
    }

    private var detentSelection: Binding<PresentationDetent> {
        Binding(
            get: { expanded ? .large : compactDetent },
            set: { expanded = ($0 == .large) }
        )
    }

    @ViewBuilder
    var compact: some View {
        switch mode {
        case .reps:
            RepsEditPopover(lift: lift, setId: setId)
        case .weight:
            WeightEditPopover(lift: lift, setId: setId)
        }
    }

    var body: some View {
        Group {
            if expanded {
                AddLiftView(lift: lift, onSave: { _ in onFullEditSave() })
            } else {
                NavigationStack {
                    compact
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear { compactHeight = proxy.size.height }
                                    .onChange(of: proxy.size.height) { _, h in compactHeight = h }
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .navigationTitle("Edit \(lift.type.string)")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    expanded = true
                                } label: {
                                    Label("Edit Full Lift", systemImage: "arrow.up.left.and.arrow.down.right")
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Cancel") {
                                    dismiss()
                                }
                            }
                        }
                }
            }
        }
        .tint(accentColor)
        .presentationDetents([compactDetent, .large], selection: detentSelection)
        .presentationDragIndicator(.visible)
    }
}
