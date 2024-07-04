//
//  LiftTypeSelector.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import SwiftUI
import SwiftData

extension String {
    func containsIgnoringCase(_ target: String) -> Bool {
        return self.range(of: target, options: .caseInsensitive) != nil
    }
}

struct LiftTypeSelector: View {
    @Binding var selectedLiftType : LiftType
    @State var searchText: String = ""
    @Environment(\.dismiss) var dismiss

    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    @Environment(\.modelContext) private var modelContext
    
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
    
    var body: some View {
        List {
            ForEach(filteredCategories.sorted(by: <), id: \.rawValue) { category in
                Section(category.rawValue) {
                    ForEach(allLiftsByCategory[category]!.sorted(), id: \.string) { lift in
                        if searchText == "" ||
                            category.rawValue.containsIgnoringCase(searchText) || 
                            lift.string.containsIgnoringCase(searchText) {
                            HStack {
                                Text(lift.string)
                                Spacer()
                                if lift == selectedLiftType {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                            .deleteDisabled(!lift.deletable)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                withAnimation {
                                    selectedLiftType = lift
                                    dismiss()
                                }
                            })
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
        name = "Custom Type"
        category = .other
        selector = NewLiftTypeMuscleGroupSelector(weights: LiftWeights())
    }
    
    init(type: UserGeneratedLiftType) {
        mode = .edit(type)
        name = type.name
        category = type.category
//        selector = NewLiftTypeMuscleGroupSelector(weights: LiftWeights())
        selector = NewLiftTypeMuscleGroupSelector(weights: type.customWeights)
    }
    
    
    var body: some View {
        
        List {
            Section {
                TextField("Type Name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(LiftCategory.allCases, id: \.rawValue) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }.disabled(mode.isEditing)
            
            Section {
                HStack {
                    MuscleGroupFrontView(selector: $selector)
                    MuscleGroupBackView(selector: $selector)
                }
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
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        switch mode {
                        case .add:
                            let type = UserGeneratedLiftType(name: name, category: category, liftWeights: selector.weights)
                            modelContext.insert(type)
                        case .edit(let type):
                            
                            // Canot update name or category
//                            break
                            type.customWeights = selector.weights
                        }
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
                }
                .disabled(name == "")
                .padding()
                .navigationTitle("New Lift Type")
            }
        }.tint(category.getColor(for: palette))
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)

    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type", category: .arms, liftWeights: LiftWeights([(.abs, 5)])))

    return NavigationStack {
        LiftTypeSelector(selectedLiftType: .constant(.backSquat))
            .modelContainer(container)
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)


    return NavigationStack {
        CreateNewTypeView()
        .modelContainer(container)
    }
}
