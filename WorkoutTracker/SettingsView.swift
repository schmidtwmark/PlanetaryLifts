//
//  SettingsView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

enum WeightUnits : String, Codable {
    case pounds = "Pounds"
    case kilograms = "Kilograms"
    
    var singleUnit: String {
        switch self {
            case .pounds: "pound"
            case .kilograms: "kilogram"
        }
    }
}

struct SettingsView: View {
    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    @Environment(\.modelContext) private var modelContext
    
    var categorizedUserGeneratedTypes : [LiftCategory: [UserGeneratedLiftType]] {
        var map : [LiftCategory: [UserGeneratedLiftType]] = [:]
        for category in LiftCategory.allCases {
           map[category] = []
        }
        for liftType in userGeneratedTypes{
            map[liftType.category]?.append(liftType)
        }
        return map
    }
    
    @AppStorage("weightUnits") var weight: WeightUnits = .pounds
    
    var body: some View {
        List {
            Section("Units") {
                Picker("Weight", selection: $weight, content:  {
                    Text("Pounds").tag(WeightUnits.pounds)
                    Text("Kilograms").tag(WeightUnits.kilograms)
                })//.pickerStyle(.segmented)
            }
            
            
            if categorizedUserGeneratedTypes.contains(where: {(_, types) in !types.isEmpty
            }) {
                Section("Custom Lift Types"){
                    ForEach(categorizedUserGeneratedTypes.sorted(by: {$0.key.rawValue < $1.key.rawValue}), id: \.key.rawValue) { category, types in
                        
                        if !types.isEmpty {
                            ForEach(types)  { type in
                                HStack {
                                    Text(type.name)
                                    Spacer()
                                    Text(type.category.rawValue).fontWeight(.light)
                                }
                            }.onDelete(perform: { indexSet in
                                let liftsToDelete = indexSet.map({index in categorizedUserGeneratedTypes[category]![index]})
                                for liftToDelete in liftsToDelete {
                                    modelContext.delete(liftToDelete)
                                    
                                }
                                
                            })
                        }
                    }
                    
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserGeneratedLiftType.self, configurations: config)
    
    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type", category: .arms))
    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type 2", category: .legs))
    return NavigationStack {
        SettingsView().modelContainer(container)
    }
}
