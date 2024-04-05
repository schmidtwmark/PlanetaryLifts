//
//  SwiftUIView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    @Environment(\.modelContext) private var modelContext
    @State var searchText = ""
    
    var liftsByType: [LiftType: [Lift]] {
        return Dictionary(grouping: lifts, by: { lift in
            lift.type
        })
    }
    
    var liftsByCategory: [LiftCategory: [Lift]] {
        return Dictionary(grouping: lifts, by: {lift in
            lift.type.category
        })
    }
    
    var allLiftsByCategory: [LiftCategory: [LiftType]] {
        generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes)
    }
    
    var filteredCategories : [LiftCategory] {
        allLiftsByCategory.keys.filter({ category in
            // there are liftTypes in this category
            !allLiftsByCategory[category]!.isEmpty &&
            // passes search
            (searchText == "" ||
            category.rawValue.containsIgnoringCase(searchText) ||
            allLiftsByCategory[category]!.contains(where: { liftType in
                liftType.string.containsIgnoringCase(searchText)
            })) &&
            // there are lifts for some lifttype in this category
            (
                allLiftsByCategory[category]!.contains(where: { liftType in liftsByType.keys.contains(where: {$0 == liftType})
                })
            )
        })
    }
    
    enum StatsType: String, Codable, CaseIterable {
        case count = "Lift Count"
        case weight = "Total Weight"
    }
    
    enum Granularity: String, Codable, CaseIterable {
        case category = "Category"
        case type = "Lift Type"
    }
    
    // Number of lifts for each category
    var categoryCounts: [(LiftCategory, Int)] {
        liftsByCategory.map({($0, $1.count)})
    }
    
    // Number of lifts for each type
    var typeCounts: [(LiftType, Int)] {
        liftsByType.map({($0, $1.count)})
    }
    
    func totalWeight(_ lifts: [Lift]) -> Double {
        return lifts.reduce(into: 0, { sum, lift in
            sum += lift.sets.reduce(into: 0, { innerSum, liftSet in
                innerSum += Double(liftSet.reps) * liftSet.weight
            })
        })
    }
    
    // Sum of weight * rep for each lift category
    var categoryWeight: [(LiftCategory, Double)] {
        liftsByCategory.map({ ($0, totalWeight($1))})
    }
    
    // Sum of weight * rep for each lift type
    var typeWeight: [(LiftType, Double)] {
        liftsByType.map({($0, totalWeight($1))})
    }

    
    
    @State
    var statsType: StatsType = .count
    
    @State
    var granularity: Granularity = .category

    var body: some View {
        
        NavigationStack {
            List {
                Section("General Stats") {
                    Picker("", selection: $statsType) {
                        ForEach(StatsType.allCases, id: \.rawValue) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }.pickerStyle(.segmented)
                    Picker("", selection: $granularity) {
                        ForEach(Granularity.allCases, id: \.rawValue) { granularity in
                            Text(granularity.rawValue).tag(granularity)}
                        
                    }.pickerStyle(.segmented)
                    Chart {
                        switch (statsType, granularity) {
                        case (.count, .category):
                            ForEach(categoryCounts, id: \.0) { category, count in
                                SectorMark(angle: .value("Count", count))
                                    .foregroundStyle(by: .value("Category", category.rawValue))
                                
                            }
                        case (.count, .type):
                            ForEach(typeCounts, id: \.0) { type, count in
                                SectorMark(angle: .value("Count", count))
                                    .foregroundStyle(by: .value("Type", type.string))
                            }
                        case (.weight, .category):
                            ForEach(categoryWeight, id: \.0) { category, weight in
                                SectorMark(angle: .value("Weight", weight))
                                    .foregroundStyle(by: .value("Category", category.rawValue))
                                
                            }
                        case (.weight, .type):
                            ForEach(typeCounts, id: \.0) { type, count in
                                SectorMark(angle: .value("Count", count))
                                    .foregroundStyle(by: .value("Type", type.string))
                            }
                        }

                    }
                }
                
                ForEach(filteredCategories, id: \.rawValue) { category in
                    Section(category.rawValue) {
                        ForEach(allLiftsByCategory[category]!, id: \.string) { liftType in
                            if let lifts = liftsByType[liftType] {
                                NavigationLink(destination: {
                                    StatItem(type: liftType, lifts: lifts)

                                }, label: {
                                    Text("\(liftType.string)")
                                })
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Stats")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for type in [LiftType.benchPress, LiftType.backSquat, LiftType.frontSquat] {
        for days in 0...50 {
            let lift = Lift(liftType: type, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
            container.mainContext.insert(lift)
            
            lift.addSet(5, weight: Double.random(in: 150...250), units: .pounds)
            lift.addSet(10, weight: Double.random(in: 100...200), units: .pounds)
        }
    }
    
    return StatsView().modelContainer(container)
}
