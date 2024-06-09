//
//  SwiftUIView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData
import Charts

func totalWeight(_ lifts: [Lift]) -> Double {
    return lifts.reduce(into: 0, { sum, lift in
        sum += lift.sets.reduce(into: 0, { innerSum, liftSet in
            innerSum += Double(liftSet.reps) * liftSet.weight.weight
        })
    })
}
func totalReps(_ lifts: [Lift]) -> Int {
    return lifts.reduce(into: 0, { sum, lift in
        sum += lift.sets.reduce(into: 0, { innerSum, liftSet in
            innerSum += liftSet.reps
        })
    })
}


let INNER_RADIUS_RATIO : MarkDimension = .ratio(0.618)
let PIE_MARK_CORNER_RADIUS: CGFloat = 5.0
let PIE_ANGULAR_INSET: CGFloat = 2


enum StatsType: String, Codable, CaseIterable {
    case count = "Lift Count"
    case weight = "Total Weight"
}

enum Granularity: String, Codable, CaseIterable {
    case category = "Category"
    case type = "Lift Type"
}


struct CategoryPieChart: View {
    
    @AppStorage(PALETTE) var palette: Palette = .main
    var liftsByCategory: [LiftCategory: [Lift]]
    @Binding var statsType: StatsType
    @State var viewModel = ViewModel()
    
    class ViewModel: ObservableObject {
        var selectedCategory: LiftCategory? = nil
    }

    var categories: [LiftCategory] {
        liftsByCategory.keys.sorted(by: <)
    }
    
    // Number of lifts for each category
    var categoryCounts: [LiftCategory: Int] {
        liftsByCategory.mapValues({$0.count})
    }
    
    // Sum of weight * rep for each lift category
    var categoryWeight: [LiftCategory: Double] {
        liftsByCategory.mapValues({totalWeight($0)})
    }
        
    func categoryMapping(_ category: LiftCategory) -> Color {
        return category.getColor(for: palette)
    }
    
    func getSector(category: LiftCategory, statsType: StatsType) -> some ChartContent {
        let isSelected = viewModel.selectedCategory == category
        let mark = switch statsType {
        case .count:
            SectorMark(angle: .value("Count", categoryCounts[category]!), innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(isSelected ? 1.0 : 0.9), angularInset: PIE_ANGULAR_INSET)
        case .weight:
            SectorMark(angle: .value("Weight", categoryWeight[category]!), innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(isSelected ? 1.0 : 0.9), angularInset: PIE_ANGULAR_INSET)
        }
        return mark
            .cornerRadius(PIE_MARK_CORNER_RADIUS)
            .foregroundStyle(by: .value("Category", category))
    }
    
    var body: some View {
        Chart(categories, id: \.rawValue) { category in
            getSector(category: category, statsType: statsType)
        }
        .chartAngleSelection(value: $viewModel.selectedCategory)
        .onChange(of: viewModel.selectedCategory, {
            print("Category change: \(String(describing: viewModel.selectedCategory))")
        })
        .chartLegend(.hidden)
        .chartForegroundStyleScale(mapping: categoryMapping)
        .scaledToFit()
        .padding()
        ScrollView(.horizontal, content: {
            HStack(alignment: .top) {
                ForEach(categories.chunked(into: 4), id: \.first!.rawValue) { chunk in
                    VStack(alignment: .leading) {
                        ForEach(chunk, id: \.rawValue) { category in
                            HStack {
                                categoryMapping(category).clipShape(Circle())
                                Text(category.rawValue)
                            }.fixedSize()
                        }
                    }
                }
            }
        })
    }
}

struct TypesPieChart: View {
    @AppStorage(PALETTE) var palette: Palette = .main
    var liftsByType: [LiftType: [Lift]]
    var liftsByCategory: [LiftCategory: [Lift]]
    @Binding var statsType: StatsType
    @State var selectedTypeString: String? = nil
    
   
    var types: [LiftType] {
        liftsByType.keys.sorted(by: <)
    }
    
    
    // Number of lifts for each type
    var typeCounts: [LiftType: Int] {
        liftsByType.mapValues({$0.count})
    }
    
    
    // Sum of weight * rep for each lift type
    var typeWeight: [LiftType: Double] {
        liftsByType.mapValues({totalWeight($0)})
    }
    
    var colorByTypeString: [String: Color] {
        
        liftsByCategory.reduce(into: [String: Color](), { output, value in
            let (category, lifts) = value
            let types = lifts.reduce(into: Set(), {typeSet, lift in
                typeSet.insert(lift.type)
            })
            // We have a category and all the types we need to worry about
            let baseColor = category.getColor(for: palette)
            let shades = baseColor.shades(count: types.count)
            zip(shades, types.sorted(by: <)).forEach({ (shade, type) in
                output[type.string] = shade
            })
        })
        
    }
    
    func getSector(liftType: LiftType, statsType: StatsType) -> some ChartContent {
        let mark = switch statsType {
        case .count:
            SectorMark(angle: .value("Count", typeCounts[liftType]!), innerRadius: INNER_RADIUS_RATIO, angularInset: PIE_ANGULAR_INSET)
        case .weight:
            SectorMark(angle: .value("Weight", typeWeight[liftType]!), innerRadius: INNER_RADIUS_RATIO, angularInset: PIE_ANGULAR_INSET)
        }
        
        return mark
            .cornerRadius(PIE_MARK_CORNER_RADIUS)
            .foregroundStyle(by: .value("Lift Type", liftType.string))
    }
    func typeMapping(_ typeString: String) -> Color {
        colorByTypeString[typeString]!
    }


    

    
    var body: some View {
        Chart(types, id: \.string){ type in
            getSector(liftType: type, statsType: statsType)
        }
        .chartAngleSelection(value: $selectedTypeString)
        .onChange(of: selectedTypeString, {
            print("Selected \(String(describing: selectedTypeString))")
        })
        .chartOverlay { _ in
            if let typeString = selectedTypeString {
                Text(typeString)
            }
        }
//        .chartOverlay { proxy in
//            GeometryReader { geometry in
//                ZStack {
//                    Rectangle().fill(.clear).contentShape(Rectangle())
//                        .gesture(
//                            DragGesture(minimumDistance: 0.0)
//                                .onEnded{ value in
//                                    // Convert the gesture location to the coordiante space of the plot area.
//                                    let origin = geometry[proxy.plotFrame!].origin
//                                    let location = CGPoint(
//                                        x: value.location.x - origin.x,
//                                        y: value.location.y - origin.y
//                                    )
//                                    // Get the x (date) and y (price) value from the location.
//                                    if let item = proxy.value(at: location, as: (String, Double).self) {
//                                        print("Selected \(item)")
//                                        if let selectedType = selectedTypeString, item.0 == selectedType{
//                                            selectedTypeString = nil
//                                        } else {
//                                            selectedTypeString = item.0
//                                        }
//                                    } else {
//                                        print("No select at location \(location)")
//                                    }
//                                }
//                        )
//                    if let typeString = selectedTypeString {
//                        Text(typeString)
//                    }
//                }
//            }
//        }
        .chartLegend(.hidden)
        .chartForegroundStyleScale(mapping: typeMapping)
        .scaledToFit()
        .padding()
        ScrollView(.horizontal, content: {
            HStack(alignment: .top) {
                ForEach(types.chunked(into: 4), id: \.first!.string) { chunk in
                    VStack(alignment: .leading) {
                        ForEach(chunk, id: \.string) { type in
                            HStack {
                                typeMapping(type.string).clipShape(Circle())
                                Text(type.string)
                            }.fixedSize()
                        }
                    }
                }
            }
        })
    }
}


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
    
    @State
    var statsType: StatsType = .count
    
    @State
    var granularity: Granularity = .category
    
    @AppStorage(PALETTE) var palette: Palette = .main
    
  
    var body: some View {
        
        NavigationStack {
            List {
                Section("General Stats") {
                    VStack {
                        Picker("", selection: $granularity.animation()) {
                            ForEach(Granularity.allCases, id: \.rawValue) { granularity in
                                Text(granularity.rawValue).tag(granularity)}
                            
                        }.pickerStyle(.segmented)
                        Picker("", selection: $statsType.animation()) {
                            ForEach(StatsType.allCases, id: \.rawValue) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }.pickerStyle(.segmented)
                        switch granularity {
                        case .category:
                            CategoryPieChart(liftsByCategory: liftsByCategory, statsType: $statsType)
                            
                        case .type:
                            TypesPieChart(liftsByType: liftsByType, liftsByCategory: liftsByCategory, statsType: $statsType)
                        }
                        
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
