//
//  LiftTypeSelector.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import SwiftUI
import SwiftData

let SECTION_COUNT_INITIAL_VALUE: Int = 5

struct LiftTypeSelector: View {
    @Binding var selectedLiftType : LiftType
    @State var searchText: String = ""
    @State var muscleGroupState: MuscleGroupState
    
    @State var suggestionsToShow = SECTION_COUNT_INITIAL_VALUE
    @State var recentsToShow = SECTION_COUNT_INITIAL_VALUE

    @Environment(\.dismiss) var dismiss

    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    var modelContext: ModelContext
    
    
    init(selectedLiftType: Binding<LiftType>, modelContext: ModelContext) {
        let state = MuscleGroupState(modelContext: modelContext)
        _muscleGroupState = State(initialValue: state)
        _selectedLiftType = selectedLiftType
        self.modelContext = modelContext
    }

    var allLiftsByCategory: [LiftCategory: [LiftType]] {
        generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes)
    }
    
    var filteredCategories : [LiftCategory] {
        LiftCategory.allCases.filter({ category in
            !allLiftsByCategory[category]!.isEmpty && (
            searchText == "" ||
            category.rawValue.containsIgnoringCase(searchText) ||
            allLiftsByCategory[category]!.contains(where: { liftType in
                liftType.string.containsIgnoringCase(searchText)
            }))
        })
    }
    
    @ViewBuilder
    func liftTypeRow(liftType: LiftType, deleteAllowed: Bool) -> some View {
        HStack {
            Text(liftType.string)
            Spacer()
            if liftType == selectedLiftType {
                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
            }
        }
        .deleteDisabled(deleteAllowed && !liftType.deletable)
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            withAnimation {
                selectedLiftType = liftType
                dismiss()
            }
        })

    }
    
    struct ShowMoreButton : View {
        @Binding var displayCount: Int
        var itemCount: Int
        
        
        var body: some View {
            if itemCount > SECTION_COUNT_INITIAL_VALUE {
                Button {
                    withAnimation {
                        if displayCount == SECTION_COUNT_INITIAL_VALUE {
                            displayCount = itemCount
                        } else {
                            displayCount = SECTION_COUNT_INITIAL_VALUE
                        }
                    }
                } label: {
                    Text(displayCount == SECTION_COUNT_INITIAL_VALUE ? "Show More" : "Show Less")
                        .font(.subheadline.smallCaps())

                }
            }
        }
    }
    
    var body: some View {
        List {
            if case .loaded(let stats) = muscleGroupState.stats, searchText == "" {
                if stats.recentLiftTypes.count > 0 {
                    Section(content: {
                        ForEach(stats.recentLiftTypes.prefix(recentsToShow)) { liftType in
                            liftTypeRow(liftType: liftType, deleteAllowed: false)
                        }
                    }, header: {
                        HStack {
                            Text("Recent Lifts")
                            Spacer()
                            ShowMoreButton(displayCount: $recentsToShow, itemCount: stats.recentLiftTypes.count)
                        }
                    })
                        
                }
                if stats.suggestedLifts.count > 0 {
                    Section(content: {
                        ForEach(stats.suggestedLifts.prefix(suggestionsToShow)) { suggestion in
                            liftTypeRow(liftType: suggestion.type, deleteAllowed: false)
                        }
                    }, header: {
                        HStack {
                            Text("Suggestions")
                            Spacer()
                            ShowMoreButton(displayCount: $suggestionsToShow, itemCount: stats.suggestedLifts.count)
                        }
                    })
                }
            }
            ForEach(filteredCategories.sorted(by: <), id: \.rawValue) { category in
                Section(category.rawValue) {
                    ForEach(allLiftsByCategory[category]!.sorted(), id: \.string) { lift in
                        if searchText == "" ||
                            category.rawValue.containsIgnoringCase(searchText) || 
                            lift.string.containsIgnoringCase(searchText) {
                            liftTypeRow(liftType: lift, deleteAllowed: true)
                        }
                    }.onDelete(perform: { indexSet in
                        let liftsToDelete = indexSet.map({index in allLiftsByCategory[category]![index]})
                        for liftToDelete in liftsToDelete {
                            switch liftToDelete {
                            case .other(_, _, let id): do {
                                try? modelContext.delete(model: UserGeneratedLiftType.self, where: #Predicate { type in
                                    type.id == id
                                })
                            }
                                default: break
                            }
                        }
                        
                    })
                }
            }
            
            Section("Custom Lift Type") {
               NavigationLink(destination: {
                   CreateNewTypeView()
               }, label: {
                   Label("New Lift Type", systemImage: "square.and.pencil")
               })
            }
        }
        .task {
            muscleGroupState.load()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

@Observable
class NewLiftTypeMuscleGroupSelector: MuscleGroupSelector {
    var selectedMuscleGroup: MuscleGroup? = nil
    var weights: LiftWeights
    
    init(weights: LiftWeights) {
        self.weights = weights
    }
    
    func getWeight(_ muscleGroup: MuscleGroup, userGeneratedTypes: [UserGeneratedLiftType]) -> Double {
        return weights.getWeight(muscleGroup)
    }
}

struct CreateNewTypeView : View {
    @State var name: String
    @State var category: LiftCategory
    @State var selector: NewLiftTypeMuscleGroupSelector
    @State var modifiers: Set<LiftModifier>
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @AppStorage(PALETTE) var palette: Palette = .main
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    
    
    enum Mode: Equatable {
        case edit(UserGeneratedLiftType)
        case add
        
        var isEditing: Bool {
            switch self {
                case .edit(_): true
                case .add: false
            }
        }
    }
    
    var mode: Mode
    
    init() {
        mode = .add
        name = ""
        category = .other
        selector = NewLiftTypeMuscleGroupSelector(weights: LiftWeights())
        modifiers = []
    }
    
    init(type: UserGeneratedLiftType) {
        mode = .edit(type)
        name = type.name
        category = type.category
        selector = NewLiftTypeMuscleGroupSelector(weights: type.liftWeights)
        modifiers = type.allowedModifiers
    }
    
    
    var body: some View {
        
        List {
            Section("Basic Info"){
                TextField("Type Name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(LiftCategory.allCases, id: \.rawValue) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }.disabled(mode.isEditing)
            
            Section("Allowed Modifications"){
                ForEach(LiftModifier.allCases, id: \.rawValue) { modifier in
                    Label(modifier.rawValue, systemImage: modifiers.contains(modifier) ? "checkmark.circle" : "circle").onTapGesture(perform: {
                        withAnimation {
                            if modifiers.contains(modifier) {
                                modifiers.remove(modifier)
                            } else {
                                modifiers.insert(modifier)
                            }
                        }
                    })
                }
            }
            
            Section("Muscle Groups"){
                HStack {
                    MuscleGroupFrontView(selector: $selector)
                    MuscleGroupBackView(selector: $selector)
                }
                .frame(maxWidth: MAX_CARD_WIDTH)
                .contentShape(Rectangle())
                .onTapGesture {
                    selector.selectedMuscleGroup = nil
                }
                if let selected = selector.selectedMuscleGroup {
                    Picker("Category", selection: Binding(get: {
                        MuscleGroupImpact(weight: selector.getWeight(selected, userGeneratedTypes: userGeneratedTypes))
                    }, set: {
                        selector.weights.map[selected] = $0.weight
                    })) {
                        ForEach(MuscleGroupImpact.allCases) { impact in
                            Text(impact.rawValue).tag(impact)
                        }
                    }
                }
            }
        }
        .toolbar {
            
            Button {
                switch mode {
                case .add:
                    let type = UserGeneratedLiftType(name: name, category: category, weights: selector.weights.sortedGroups, allowedModifiers: modifiers)
                    modelContext.insert(type)
                case .edit(let type):
                    
                    // Canot update name or category
//                            break
                    type.weights = selector.weights.sortedGroups.map({UserGeneratedLiftType.LiftWeight(muscleGroup: $0.0, weight: $0.1)})
                    type.allowedModifiers = modifiers
                }
                dismiss()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(name == "")
        }
        .navigationTitle("New Lift Type")
        .tint(category.getColor(for: palette))
    }
}

struct LiftTypeSelectorWrapper: View {
    @Environment(\.modelContext) var modelContext
    
    
    var body: some View {
        NavigationStack {
            LiftTypeSelector(selectedLiftType: .constant(.backSquat), modelContext: modelContext)
        }
    }
}

#Preview("Add Lift"){
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)

    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type", category: .arms, weights: [(.abs, 5.0)]))
    var lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline, .narrowGrip], notes: "Notes notes notes notes notes notes notes")
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))
    
    lift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*10))
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 250.0, units: .pounds))
    
    lift = Lift(liftType: .deadlift, timestamp: Date.now.addingTimeInterval(-60*10))
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))

    return LiftTypeSelectorWrapper().modelContainer(container)
}

#Preview("Create New Type") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    


    return NavigationStack {
        CreateNewTypeView()
        .modelContainer(container)
    }
}
