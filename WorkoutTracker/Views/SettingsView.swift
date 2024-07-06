//
//  SettingsView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData



extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
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
    
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @State var importSheetPresented = false
    @State var exportSheetPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    
                    Picker(selection: $weightUnits, content:  {
                        Text("Pounds").tag(WeightUnits.pounds)
                        Text("Kilograms").tag(WeightUnits.kilograms)
                    }, label: {
                        Label("Weight", systemImage: "scalemass")
                    })
                    .onChange(of: weightUnits, { (old, new) in
                        // TODO: figure out how to do this in the background and show progress
                        let lifts = try! modelContext.fetch(FetchDescriptor<Lift>())
                        for lift in lifts {
                            let newSets = lift.sets.map({$0.convert(to: new)})
                            lift.sets = newSets
                        }
                    })
                }
                #if DEBUG
                Section("Debug Stuff") {
                    NavigationLink("Sticker Generator") {
                        StickerGeneratorView()
                    }
                }
                #endif
                
                
                if categorizedUserGeneratedTypes.contains(where: {(_, types) in !types.isEmpty }) {
                    Section("Custom Lift Types"){
                        ForEach(categorizedUserGeneratedTypes.sorted(by: {$0.key.rawValue < $1.key.rawValue}), id: \.key.rawValue) { category, types in
                            
                            if !types.isEmpty {
                                ForEach(types)  { type in
                                    NavigationLink(destination: {
                                        CreateNewTypeView(type: type)
                                    }, label: {
                                        HStack {
                                            Text(type.name)
                                            Spacer()
                                            Text(type.category.rawValue).fontWeight(.light)
                                        }
                                    })
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
                
                Section("Backup and Restore") {
                    Button {
                        importSheetPresented = true
                    } label: {
                        Label("Import Lifts", systemImage: "square.and.arrow.down.on.square")
                    }
                    Button {
                        exportSheetPresented = true
                    } label: {
                        Label("Export Lifts", systemImage: "square.and.arrow.up.on.square")
                    }
                }
               
                if let version = Bundle.main.releaseVersionNumber, let build = Bundle.main.buildVersionNumber {
                    Section("About") {
                        HStack {
                            Label("Version Number", systemImage: "calendar")
                            Spacer()
                            Text(version)
                        }
                        HStack {
                            Label("Build Number", systemImage: "swift")
                            Spacer()
                            Text(build)
                        }
                    }
                }
                
                Section("Shameless Self Promotion") {
                    
                    Link(destination: URL(string:"https://apps.apple.com/qa/developer/mark-schmidt/id1502505700")!) {
                        Label("My Other Apps", systemImage: "storefront")
                    }
                }

            }
            .navigationTitle("Settings")
            .sheet(isPresented: $importSheetPresented, content: {
                ImportSheet()
            })
            .sheet(isPresented: $exportSheetPresented, content: {
                ExportSheet()
            })
            
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for type in [LiftType.benchPress, LiftType.backSquat, LiftType.frontSquat] {
        for days in 0...Int.random(in: 30...70) {
            let lift = Lift(liftType: type, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
            container.mainContext.insert(lift)
            
            for _ in 0...Int.random(in: 1...5) {
                let reps = [5, 10, 15].randomElement()!
                lift.addSet(reps, weight: Double.random(in: 150...250), units: .pounds)
                lift.addSet(reps, weight: Double.random(in: 100...200), units: .pounds)
            }
        }
            
    }
    
    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type", category: .arms))
    container.mainContext.insert(UserGeneratedLiftType(name: "User Generated Type 2", category: .legs))
    return
        SettingsView().modelContainer(container)
}
