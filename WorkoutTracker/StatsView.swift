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
    
    var categories: [LiftCategory] {
        liftsByCategory.keys.sorted(by: <)
    }
    
    var types: [LiftType] {
        liftsByType.keys.sorted(by: <)
    }
    
    // Number of lifts for each category
    var categoryCounts: [LiftCategory: Int] {
        liftsByCategory.mapValues({$0.count})
    }
    
    // Number of lifts for each type
    var typeCounts: [LiftType: Int] {
        liftsByType.mapValues({$0.count})
    }
    
    func totalWeight(_ lifts: [Lift]) -> Double {
        return lifts.reduce(into: 0, { sum, lift in
            sum += lift.sets.reduce(into: 0, { innerSum, liftSet in
                innerSum += Double(liftSet.reps) * liftSet.weight.weight
            })
        })
    }
    
    // Sum of weight * rep for each lift category
    var categoryWeight: [LiftCategory: Double] {
        liftsByCategory.mapValues({totalWeight($0)})
    }
    
    // Sum of weight * rep for each lift type
    var typeWeight: [LiftType: Double] {
        liftsByType.mapValues({totalWeight($0)})
    }

    
    
    @State
    var statsType: StatsType = .count
    
    @State
    var granularity: Granularity = .category
    
    func getSector(category: LiftCategory, statsType: StatsType) -> some ChartContent {
        let mark = switch statsType {
        case .count:
            SectorMark(angle: .value("Count", categoryCounts[category]!))
        case .weight:
            SectorMark(angle: .value("Weight", categoryWeight[category]!))
        }
        return mark.foregroundStyle(by: .value("Category", category.rawValue))
    }
    
    func getSector(liftType: LiftType, statsType: StatsType) -> some ChartContent {
        let mark = switch statsType {
        case .count:
            SectorMark(angle: .value("Count", typeCounts[liftType]!))
        case .weight:
            SectorMark(angle: .value("Weight", typeWeight[liftType]!))
        }
        return mark.foregroundStyle(by: .value("Lift Type", liftType.string))
    }

    var body: some View {
        
        NavigationStack {
            List {
                Section("General Stats") {
                    Picker("", selection: $statsType.animation()) {
                        ForEach(StatsType.allCases, id: \.rawValue) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }.pickerStyle(.segmented)
                    Picker("", selection: $granularity.animation()) {
                        ForEach(Granularity.allCases, id: \.rawValue) { granularity in
                            Text(granularity.rawValue).tag(granularity)}
                        
                    }.pickerStyle(.segmented)
                    Chart {
                        
                        switch granularity {
                        case .category:
                            ForEach(categories, id: \.rawValue) { category in
                                getSector(category: category, statsType: statsType)
                            }
                        case .type:
                            ForEach(types, id: \.string) { type in
                                getSector(liftType: type, statsType: statsType)
                            }
                        }
//                        
//                        
//                        switch (statsType, granularity) {
//                        case (.count, .category):
//                            ForEach(categoryCounts, id: \.0) { category, count in
//                                SectorMark(angle: .value("Count", count))
//                                    .foregroundStyle(by: .value("Category", category.rawValue))
//                                
//                            }
//                        case (.count, .type):
//                            ForEach(typeCounts, id: \.0) { type, count in
//                                SectorMark(angle: .value("Count", count))
//                                    .foregroundStyle(by: .value("Type", type.string))
//                            }
//                        case (.weight, .category):
//                            ForEach(categoryWeight, id: \.0) { category, weight in
//                                SectorMark(angle: .value("Weight", weight))
//                                    .foregroundStyle(by: .value("Category", category.rawValue))
//                                
//                            }
//                        case (.weight, .type):
//                            ForEach(typeCounts, id: \.0) { type, count in
//                                SectorMark(angle: .value("Count", count))
//                                    .foregroundStyle(by: .value("Type", type.string))
//                            }
//                        }
//
                    }
                }
                
                ForEach(filteredCategories.sorted(by: <), id: \.rawValue) { category in
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
    
    return StatsView().modelContainer(container)
}
