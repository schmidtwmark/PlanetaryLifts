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
import Collections

func totalWeight(_ lifts: [Lift]) -> Double {
    return lifts.reduce(into: 0, { sum, lift in
        sum += lift.sets.reduce(into: 0, { innerSum, liftSet in
            if lift.weighted {
                innerSum += Double(liftSet.reps) * liftSet.weight.weight
            }
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

@Observable final class ChartViewModel<T: Hashable & Comparable & Sendable>{
    
    enum ChartData {
        case loading
        case loaded(categoryCounts: [ChartItem])
    }
    
    struct ChartItem : Comparable, Identifiable, Hashable {
        var category: T
        var count: Double
        
        var id: Int {
            category.hashValue
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            return lhs.count < rhs.count
        }
    }
    
    var selectedItem: ChartItem? = nil
    var chartData: ChartData = .loading
    
    func load(liftsByCategory: Dictionary<T, [Lift]>?, countFn: ([Lift]) -> Double) {
        if let liftsByCategory = liftsByCategory {
            
            var categoryHeap = liftsByCategory.reduce(into: Heap<ChartItem>(), { output, item in
                let count = countFn(item.value)
                
                if output.count < 20 {
                    output.insert(ChartItem(category: item.key, count: count))
                } else if let min = output.min, min.count < count {
                    let _ = output.popMin()
                    output.insert(ChartItem(category: item.key, count: count))
                }
            })
            
            var categoryCounts: [ChartItem] = []
            while !categoryHeap.isEmpty {
                if let max = categoryHeap.popMax() {
                    categoryCounts.append(max)
                }
            }
            chartData = .loaded(categoryCounts: categoryCounts)
        } else {
            chartData = .loading
        }
    }
    
    func getCategoryBy(count: Double) -> ChartItem? {
        if case .loaded(let categoryCounts) = chartData {
            var sum = 0.0
            for item in categoryCounts {
                sum += item.count
                if count <= sum {
                    return item
                }
            }
        }
        return nil
    }
}


struct CategoryPieChart<T: Hashable & Comparable & Identifiable & Sendable>: View {
    
    @AppStorage(PALETTE) var palette: Palette = .main
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @State var viewModel: ChartViewModel<T>
    @State var legendPosition: Int? = nil
    
    var title: String
    
    func color(_ string: String)  -> Color {
        if string == "first" {
            return Color.gray
        } else if string == "second" {
            return Color.gray.darker(by: 10.0)
        }
        return colorMapping(string)
    }
    
    var statsType: StatsType
    var countFn: ([Lift]) -> Double
    var colorMapping: (String) -> Color
    var stringMapping: (T) -> String
    var liftsByCategory: Dictionary<T, [Lift]>?
    
    init(title: String,
         liftsByCategory: Dictionary<T, [Lift]>?,
         statsType: StatsType,
         colorMapping: @escaping (String) -> Color,
         stringMapping: @escaping (T) -> String,
         countFn: @escaping ([Lift]) -> Double) {
        self.liftsByCategory = liftsByCategory
        self.viewModel = ChartViewModel<T>()
        self.colorMapping = colorMapping
        self.stringMapping = stringMapping
        self.title = title
        self.statsType = statsType
        self.countFn = countFn
    }
    
    func refresh() {
        viewModel.load(liftsByCategory: liftsByCategory, countFn: countFn)
    }

    
    var body: some View {
        VStack {
            VStack {
                Text(title).font(.headline)
                ZStack {
                    let chartWidth = min(UIScreen.screenWidth - (2 * CARD_MARGIN), MAX_CARD_WIDTH) - (2 * CHART_PADDING)
                    Chart {
                        if case .loaded(let categoryCounts) = viewModel.chartData {
                            ForEach(categoryCounts) { chartItem in
                                let isSelected = viewModel.selectedItem == chartItem
                                let label: String = switch statsType {
                                case .count:
                                    "Count"
                                case .weight:
                                    "Weight"
                                }
                                
                                SectorMark(angle: .value(label, chartItem.count), innerRadius: INNER_RADIUS_RATIO, outerRadius: .ratio(isSelected ? 1.0 : 0.9), angularInset: PIE_ANGULAR_INSET)
                                    .cornerRadius(PIE_MARK_CORNER_RADIUS)
                                    .foregroundStyle(by: .value("Category", stringMapping(chartItem.category)))
                                
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
                    .frame(width: chartWidth, height: chartWidth)
                    .chartOverlay { proxy in
                        if case .loaded(let categoryCounts) = viewModel.chartData {
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
                                                        if let item = viewModel.getCategoryBy(count: item) {
                                                            withAnimation {
                                                                if item == viewModel.selectedItem{
                                                                    viewModel.selectedItem = nil
                                                                } else {
                                                                    viewModel.selectedItem = item
                                                                    if let idx = categoryCounts.firstIndex(of: item) {
                                                                        legendPosition = (idx / 2)
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
                    
                    if case .loading = viewModel.chartData {
                        ProgressView().tint(.gray)
                    }
                    if let item = viewModel.selectedItem {
                        VStack {
                            Text(stringMapping(item.category))
                            switch statsType {
                            case .count:
                                Text(item.count.displayString(singleUnit: "lift"))
                            case .weight:
                                Text(item.count.displayString(singleUnit: weightUnits.shortSingleUnit ))
                            }
                        }
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: viewModel.selectedItem)
            .chartLegend(.hidden)
            .chartForegroundStyleScale(mapping: color)
            .padding(CHART_PADDING)
            if case .loaded(let categoryCounts) = viewModel.chartData {
                StatsLegend(
                            chunkSize: 2,
                            categories: categoryCounts,
                            selectedCategory: $viewModel.selectedItem,
                            stringMapping: {stringMapping($0.category)},
                            colorMapping: colorMapping,
                            legendPosition: $legendPosition)
            } else {
                StatsLegend(
                            chunkSize: 2,
                            categories: ["Placeholder 1", "Placeholder 2"],
                            selectedCategory: Binding.constant(nil),
                            stringMapping: {$0},
                            colorMapping: {_ in Color.gray},
                            legendPosition: Binding.constant(0)
                )
                .redacted(reason: .placeholder)
            }
        }
        .padding(CARD_MARGIN)
        .frame(width: min(UIScreen.screenWidth - (2 * CARD_MARGIN), MAX_CARD_WIDTH))
        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .onChange(of: liftsByCategory, {
            refresh()
        })
        .task {
            refresh()
        }
    }
}



struct StatsView: View {
    
    @Observable
    final class ViewModel {
        var modelContext: ModelContext
        var stats: State = .loading
        var searchText = ""
        // TODO: load palette from user defaults
        var palette: Palette = .main

        enum State {
            case loading
            case loaded(LoadedStats)
            case error
        }
        
         
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
        }

        var allLiftsByCategory: [LiftCategory: [LiftType]] {
            if case .loaded(let loadedStats) = stats {
                return generateAllLiftsByCategory(userGeneratedTypes: loadedStats.userGeneratedTypes)
            } else {
                return [:]
            }
        }
        
        var loadedStats: LoadedStats? {
            if case .loaded(let loadedStats) = stats {
                return loadedStats
            } else {
                return nil
            }
        }
        
        var filteredCategories : [LiftCategory] {
            if case .loaded(let loadedStats) = stats {
                return allLiftsByCategory.keys.filter({ category in
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
                        allLiftsByCategory[category]!.contains(where: { liftType in loadedStats.liftsByType.keys.contains(liftType)
                        })
                    )
                })
            } else {
                return []
            }
        }    
   
    
        var presentTypes: Set<LiftType> {
            if case .loaded(let loadedStats) = stats {
                Set(loadedStats.liftsByType.keys)
            } else {
                Set()
            }
        }


        func load() {
            stats = .loading
            do {
                let typesDescriptor = FetchDescriptor<UserGeneratedLiftType>()
                let userGeneratedTypes = try modelContext.fetch(typesDescriptor)
                
                let liftsDescriptor = FetchDescriptor<Lift>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                let lifts = try modelContext.fetch(liftsDescriptor)
                
                let liftsByType = Dictionary.init(grouping: lifts, by: { $0.type })
                let liftsByCategory = Dictionary.init(grouping: lifts, by: { $0.type.category })
                
                let colorByTypeString = liftsByCategory.reduce(into: [String: Color](), { output, section in
                    let lifts = section.value
                    let category = section.key

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
                
                stats = .loaded(.init(liftsByType: liftsByType, 
                                      liftsByCategory: liftsByCategory,
                                      userGeneratedTypes: userGeneratedTypes,
                                      colorByTypeString: colorByTypeString))
                
            } catch {
                print("Fetch failed ")
            }
        }
    }
    
    struct LoadedStats {
        var liftsByType: [LiftType: [Lift]]
        var liftsByCategory: [LiftCategory: [Lift]]
        var userGeneratedTypes: [UserGeneratedLiftType]
        var colorByTypeString: [String: Color]
    }
    
    init(modelContext: ModelContext) {
        let state = ViewModel(modelContext: modelContext)
        _model = State(initialValue: state)
    }
    
    @State var model: ViewModel
    @State var showStatsForType: LiftType? = nil
    @State var selectedCard: String? = nil
    
    @State
    var granularity: Granularity = .category
    
    @AppStorage(PALETTE) var palette: Palette = .main
    
    @ViewBuilder
    func debugCard(_ text: String) -> some View {
        Text(text)
            .frame(width: 275, height: 275)
            .background(.gray).id(text)
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    if let loadedStats = model.loadedStats, loadedStats.liftsByCategory.count == 0 {
                        HStack {
                            Spacer()
                            Text("Add lifts to start tracking stats!")
                            Spacer()
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 20.0) {
                                CategoryPieChart<LiftCategory>(
                                    title: "Lift Count by Category",
                                    liftsByCategory: model.loadedStats?.liftsByCategory,
                                    statsType: .count,
                                    colorMapping: {LiftCategory(rawValue: $0)!.getColor(for: palette)},
                                    stringMapping: {$0.rawValue},
                                    countFn: {Double($0.count)})
                                .id("Category Count")
                                CategoryPieChart<LiftCategory>(
                                    title: "Weight by Category",
                                    liftsByCategory: model.loadedStats?.liftsByCategory,
                                    statsType: .weight,
                                    colorMapping: {LiftCategory(rawValue: $0)!.getColor(for: palette)},
                                    stringMapping: {$0.rawValue},
                                    countFn: {totalWeight($0)})
                                .id("Category Weight")
                                CategoryPieChart<LiftType>(
                                    title: "Lift Count by Lift Type",
                                    liftsByCategory: model.loadedStats?.liftsByType,
                                    statsType: .count,
                                    colorMapping: {model.loadedStats?.colorByTypeString[$0] ?? .gray},
                                    stringMapping: {$0.string},
                                    countFn: {Double($0.count)})
                                .id("Lift Count")
                                CategoryPieChart<LiftType>(
                                    title: "Weight by Lift Type",
                                    liftsByCategory: model.loadedStats?.liftsByType,
                                    statsType: .weight,
                                    colorMapping: {model.loadedStats?.colorByTypeString[$0] ?? .gray},
                                    stringMapping: {$0.string},
                                    countFn: {totalWeight($0)})
                                .id("Lift Weight")
                            }
                            .scrollTargetLayout()
                        }
                        // Disabled because scroll position adds lag to the stats view screen--perhaps due to loading?
                        .scrollPosition(id: $selectedCard)
                        .sensoryFeedback(.selection, trigger: selectedCard)
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, CARD_MARGIN)
                        .scrollIndicators(.hidden)
                        VStack(spacing: 20.0){
                            ForEach(model.filteredCategories.sorted(by: <), id: \.rawValue) { category in
                                VStack {
                                    Section {
                                        HStack {
                                            Text(category.rawValue.uppercased())
                                            Spacer()
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                        .padding(.leading, 15.0)
                                        VStack(spacing: 0.0) {
                                            let types = model.allLiftsByCategory[category]!.sorted(by: <).filter({model.presentTypes.contains($0)})
                                            if types.count > 0 {
                                                Divider().opacity(0.0)
                                                ForEach(types, id: \.string) { liftType in
                                                    HStack {
                                                        Text("\(liftType.string)")
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 15.0)
                                                    .padding(.vertical, LIST_ROW_VERTICAL_PADDING)
                                                    .onTapGesture(perform: {
                                                        showStatsForType = liftType
                                                    })
                                                    Divider().padding(.leading).opacity(types.last == liftType ? 0.0 : 1.0)
                                                }
                                            }
                                            
                                        }
                                        .contentShape(Rectangle())
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                        
                                    }
                                }
                            }
                        }.padding()
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            #if DEBUG
            .onChange(of: selectedCard, {
                print("Changed selected card \(String(describing: selectedCard))")
            })
            #endif
            .navigationTitle("Stats")
            .searchable(text: $model.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(item: $showStatsForType) { type in
                StatItem(type: type, modelContext: model.modelContext)
                
            }
        }
        .task {
            model.load()
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
    return StatsView(modelContext: container.mainContext)
}


#Preview("Overloaded") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for type in LiftType.allCases {
        for days in 0...Int.random(in: 30...35) {
            let lift = Lift(liftType: type, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
            container.mainContext.insert(lift)
            
            for _ in 0...Int.random(in: 1...5) {
                let reps = [5, 10, 15].randomElement()!
                lift.addSet(reps, weight: Double.random(in: 150...250), units: .pounds)
                lift.addSet(reps, weight: Double.random(in: 100...200), units: .pounds)
            }
        }
            
    }
    return StatsView(modelContext: container.mainContext)
}
