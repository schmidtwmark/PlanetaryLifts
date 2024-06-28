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

struct CreateNewTypeView : View {
    @State var name: String = ""
    @State var category: LiftCategory = .other
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        List {
            Section {
                TextField("Type Name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(LiftCategory.allCases, id: \.rawValue) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        modelContext.insert(UserGeneratedLiftType(name: name, category: category))
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
                .padding()
                .navigationTitle("New Lift Type")
            }
        }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserGeneratedLiftType.self, configurations: config)
    
    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type", category: .arms))

    return NavigationStack {
        LiftTypeSelector(selectedLiftType: .constant(.backSquat))
            .modelContainer(container)
    }
}
