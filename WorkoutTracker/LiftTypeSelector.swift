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
        var categoryMap = LiftType.liftsByCategory
        for type in userGeneratedTypes {
            categoryMap[type.category]!.append(LiftType.other(name: type.name, category: type.category, id: type.id))
        }
        return categoryMap
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
            ForEach(filteredCategories, id: \.rawValue) { category in
                Section(category.rawValue) {
                    ForEach(allLiftsByCategory[category]!, id: \.string) { lift in
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
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
