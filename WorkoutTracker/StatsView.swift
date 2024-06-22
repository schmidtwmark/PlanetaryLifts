//
//  SwiftUIView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData
import Charts
import SectionedQuery
import Observation

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

@Observable final class ChartViewModel<T: Hashable & Comparable>{
    
    enum ChartData {
        case loading
        case loaded(categories: [T], categoryCounts: [T: Double], categoryWeight: [T: Double])
    }
    
    var selectedCategory: T? = nil
    var chartData: ChartData = .loading
    var liftsByCategory : SectionedResults<T, Lift>
    
    init(liftsByCategory: SectionedResults<T, Lift>) {
        self.liftsByCategory = liftsByCategory
    }
    
    func load() async {
        let start = ContinuousClock.now
        let categories = liftsByCategory.sections.sorted(by: {$0.id < $1.id}).map({$0.id})
        let categoryCounts = liftsByCategory.sections.reduce(into: [T: Double](), { output, section in
            output[section.id] = Double(section.elements.count)
        })
        
        let categoryWeight = liftsByCategory.sections.reduce(into: [T: Double](), {
            output, section in
            output[section.id] = totalWeight(section.elements)
        })
        
        try? await Task.sleep(until: start + .milliseconds(1000))
        chartData = .loaded(categories: categories, categoryCounts: categoryCounts, categoryWeight: categoryWeight)

    }
    
    func getCategoryBy(count: Double, statsType: StatsType) -> T? {
        if case .loaded(let categories, let categoryCounts, let categoryWeight) = chartData {
            var sum = 0.0
            for category in categories {
                let delta = switch statsType {
                case .count:
                    categoryCounts[category]!
                case .weight:
                    categoryWeight[category]!
                }
                sum += delta
                if count <= sum {
                    return category
                }
            }
        }
        return nil
    }
}


struct CategoryPieChart<T: Hashable & Comparable & Identifiable & Defaultable>: View {
    
    @AppStorage(PALETTE) var palette: Palette = .main
    @Binding var statsType: StatsType
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @State var viewModel: ChartViewModel<T>
    
    
    func color(_ string: String)  -> Color {
        if string == "first" {
            return Color.gray
        } else if string == "second" {
            return Color.gray.darker(by: 10.0)
        }
        return colorMapping(string)
    }
    var colorMapping: (String) -> Color
    var stringMapping: (T) -> String
    
    init(liftsByCategory: SectionedResults<T, Lift>, statsType: Binding<StatsType>, colorMapping: @escaping (String) -> Color, stringMapping: @escaping (T) -> String) {
        self.viewModel = ChartViewModel<T>(liftsByCategory: liftsByCategory)
        self._statsType = statsType
        self.colorMapping = colorMapping
        self.stringMapping = stringMapping
    }
    
   
    
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                Chart {
                    if case .loaded(let categories, let categoryCounts, let categoryWeight) = viewModel.chartData {
                        ForEach(categories) { category in
                            let isSelected = viewModel.selectedCategory == category
                            let value : PlottableValue<Double> = switch statsType {
                            case .count:
                                    .value("Count", categoryCounts[category]!)
                            case .weight:
                                    .value("Weight", categoryWeight[category]!)
                            }
                            
                            SectorMark(angle: value, innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(isSelected ? 1.0 : 0.9), angularInset: PIE_ANGULAR_INSET)
                                .cornerRadius(PIE_MARK_CORNER_RADIUS)
                                .foregroundStyle(by: .value("Category", stringMapping(category)))
                        }
                    } else {
                        SectorMark(angle: .value("Count", 0.8), innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(0.9), angularInset: PIE_ANGULAR_INSET)
                            .cornerRadius(PIE_MARK_CORNER_RADIUS)
                            .foregroundStyle(by: .value("Category", "first"))
                        SectorMark(angle: .value("Count", 0.2), innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(0.9), angularInset: PIE_ANGULAR_INSET)
                            .cornerRadius(PIE_MARK_CORNER_RADIUS)
                            .foregroundStyle(by: .value("Category", "second"))
                    }
                }
                if case .loading = viewModel.chartData {
                    ProgressView().tint(.gray)
                }
                if let category = viewModel.selectedCategory, case .loaded(_, let categoryCounts, let categoryWeight) = viewModel.chartData {
                    VStack {
                        Text(stringMapping(category))
                        switch statsType {
                        case .count:
                            Text(displayString(number: categoryCounts[category]!, singleUnit: "lift"))
                        case .weight:
                            Text(displayString(number: categoryWeight[category]!, singleUnit: weightUnits.shortSingleUnit ))
                        }
                    }
                }

            }
            .chartOverlay { proxy in                                                      if case .loaded(let categories, _, _) = viewModel.chartData {
                    GeometryReader { geometry in
                        ZStack(alignment: .center) {
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded{ value in
                                            // Convert the gesture location to the coordiante space of the plot area.
                                            let origin = geometry[proxy.plotFrame!].origin
                                            let location = CGPoint(
                                                x: value.location.x - origin.x,
                                                y: value.location.y - origin.y
                                            )
                                            let angle = proxy.angle(at: location)
                                            if let item = proxy.value(atAngle: angle, as: Double.self) {
                                                if let category = viewModel.getCategoryBy(count: item, statsType: statsType) {
                                                    withAnimation {
                                                        if category == viewModel.selectedCategory {
                                                            viewModel.selectedCategory = nil
                                                        } else {
                                                            viewModel.selectedCategory = category
                                                            if let idx = categories.firstIndex(of: category) {
                                                                scrollProxy.scrollTo(idx / 2)
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                )
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale(mapping: color)
            .scaledToFit()
            .padding()
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    if case .loaded(let categories, _, _) = viewModel.chartData {
                        StatsLegend(
                                    chunkSize: 2,
                                    categories: categories,
                                    selectedCategory: $viewModel.selectedCategory,
                                    stringMapping: stringMapping,
                                    colorMapping: colorMapping)
                    }
                }
                
                .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                .scrollIndicators(.hidden)
            }
        }.task {
            await viewModel.load()
        }
    }
}



struct StatsView: View {
    @Query var userGeneratedTypes : [UserGeneratedLiftType]
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    @Environment(\.modelContext) private var modelContext
    @State var searchText = ""
    @State var showStatsForType: LiftType?
    
    @SectionedQuery(\Lift.type) var liftsByType: SectionedResults<LiftType, Lift>
    @SectionedQuery(\Lift.type.category) var liftsByCategory: SectionedResults<LiftCategory, Lift>
    
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
                allLiftsByCategory[category]!.contains(where: { liftType in liftsByType.sections.contains(where: {$0.id == liftType})
                })
            )
        })
    }
    
    var presentTypes: Set<LiftType> {
        Set(liftsByType.sections.map({$0.id}))
    }
    
    var colorByTypeString: [String: Color] {
        liftsByCategory.sections.reduce(into: [String: Color](), { output, section in
            let lifts = section.elements
            let category = section.id
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

    @State
    var statsType: StatsType = .count
    
    @State
    var granularity: Granularity = .category
    
    @AppStorage(PALETTE) var palette: Palette = .main
    
  
    var body: some View {
        
        NavigationStack {
            List {
                if searchText.isEmpty {
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
                                CategoryPieChart<LiftCategory>(
                                    liftsByCategory: liftsByCategory,
                                    statsType: $statsType,
                                    colorMapping: {LiftCategory(rawValue: $0)!.getColor(for: palette)},
                                    stringMapping: {$0.rawValue})
                                
                            case .type:
                                CategoryPieChart<LiftType>(
                                    liftsByCategory: liftsByType,
                                    statsType: $statsType,
                                    colorMapping: {colorByTypeString[$0]!},
                                    stringMapping: {$0.string})
                            }
                            
                        }
                    }
                }
                
                ForEach(filteredCategories.sorted(by: <), id: \.rawValue) { category in
                    Section(category.rawValue) {
                        ForEach(allLiftsByCategory[category]!, id: \.string) { liftType in
                            if presentTypes.contains(liftType) {
                                HStack {
                                    Text("\(liftType.string)")
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture(perform: {
                                    showStatsForType = liftType
                                })
                                
                            }
                        }
                    }
                }
                .sheet(item: $showStatsForType) { type in
                    StatItem(type: type)
                }
                .navigationTitle("Stats")
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
    
    return StatsView().modelContainer(container)
}
