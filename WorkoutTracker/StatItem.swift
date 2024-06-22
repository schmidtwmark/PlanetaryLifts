//
//  StatItem.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/3/24.
//

import SwiftUI
import Charts
import SwiftData
import Observation

func repToString(_ reps: Int) -> String {
    if reps == 1 {
        return "1 rep"
    } else {
        return "\(reps) reps"
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
}

struct MaxesBarChart : View {
    
    var maxes: [Int: Double]
    var colorByRepCount: (String, Palette) -> Color
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @Binding var selection: String?
    @AppStorage(PALETTE) var palette: Palette = .main
    
    var body: some View {
        VStack {
            Chart {
                ForEach(maxes.sorted(by: <), id: \.key) { reps, max in
                    BarMark(x: .value("Reps", repToString(reps)), y: .value("Weight", max))
                        .annotation(content: {
                            Text(displayString(number: max, singleUnit: weightUnits.shortSingleUnit))
                                .opacity(selection == repToString(reps) ? 1.0 : 0.0)

                        })
                        .foregroundStyle(by: .value("Reps", repToString(reps)))
                }
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale(mapping: { data in
                return colorByRepCount(data, palette)
            })
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    ZStack {
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
                                        if let item = proxy.value(at: location, as: (String, Double).self) {
                                            withAnimation {
                                                if let selectedReps = selection,  selectedReps == item.0 {
                                                    selection = .none
                                                } else {
                                                    selection = item.0
                                                }
                                            }
                                        }
                                    }
                            )
                        
                    }
                }
            }
        }
    }
}


@Observable final class ViewModel {
    
    enum StatItemData {
        case loading
        case loaded(maxes: [Int: Double],
                    shadeIndexByRepCount: [String: Int],
                    allTimeMax: Double,
                    filteredLifts: [Lift],
                    daysRange: Int
        )
    }
    var type: LiftType
    var data: StatItemData = .loading

    func colorByRepCount(_ repString: String, _ palette: Palette) -> Color {
        if case .loaded(let maxes, let shadeIndexByRepCount, _, _, _) = data {
            type.category
                .getColor(for: palette)
                .shades(count: maxes.count)[shadeIndexByRepCount[repString]!]
        } else {
            Color.gray
        }
    }
        
    
    init(type: LiftType) {
        self.type = type
    }
    
    func load(lifts: [Lift]) {
        
        let filteredLifts = lifts.filter({$0.type == type})
        
        let maxes = filteredLifts.reduce(into: [Int: Double](), { result, lift in
            let liftMaxes = lift.maxes()
            for (reps, maxWeight) in liftMaxes {
                if let maxForReps = result[reps], maxWeight < maxForReps {
                    return
                }
                result[reps] = maxWeight
            }
        })
        let shadeIndexByRepCount = zip((0..<maxes.count), maxes.sorted(by: <)).reduce(into: [String: Int](), { dict, values in
            let (index, (reps, _)) = values
            dict[repToString(reps)] = index
        })
        
        let allTimeMax = maxes.values.max()!
        
        let daysRange = Int(filteredLifts.first!.timestamp.timeIntervalSince(filteredLifts.last!.timestamp))
        self.data = .loaded(maxes: maxes, shadeIndexByRepCount: shadeIndexByRepCount, allTimeMax: allTimeMax, filteredLifts: filteredLifts, daysRange: daysRange)
    }
}


struct StatItem: View {
    var type: LiftType
    
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]

    
    @AppStorage(WEIGHT_UNITS) var weightUnits: WeightUnits = .pounds
    @AppStorage(PALETTE) var palette: Palette = .main
    @State var viewModel: ViewModel
    @State var selectedRepCount: String?
    
    @Environment(\.dismiss) var dismiss

    init(type: LiftType) {
        self.type = type
        self.viewModel = ViewModel(type: type)
    }
    


    var body: some View {
        NavigationStack {
            List {
                switch viewModel.data {
                case .loading:
                    ProgressView()
                case .loaded(let maxes, _, let allTimeMax, _, _):
                    Section {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
                            StatBlock(description: "All Time Max", unit: weightUnits.shortSingleUnit, number: allTimeMax)
                            StatBlock(description: "Total Weight", unit: weightUnits.shortSingleUnit, number: totalWeight(lifts))
                            StatBlock(description: "Total Reps", unit: "Rep", number: Double(totalReps(lifts)))
                            StatBlock(description: "Total Lifts", unit: "Lift", number: Double(lifts.count))
                            
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    
                    // Only show this
                    if maxes.count > 1 {
                        Section("Maxes") {
                            MaxesBarChart(maxes: maxes,
                                          colorByRepCount: viewModel.colorByRepCount,
                                          selection: $selectedRepCount
                            )
                            .frame(minWidth: 150, minHeight: 200)
                        }
                    }
                    
                    Section("Progress") {
                        WeightProgressView(viewModel: viewModel, selectedReps: $selectedRepCount)
                    }
                }
            }
            .toolbar {
                if case .loaded(let maxes, _, _, _, _) = viewModel.data, maxes.count > 1 {
                    ToolbarItem(placement: .bottomBar) {
                        ScrollView(.horizontal) {
                            HStack(alignment: .top) {
                                StatsLegend(
                                    chunkSize: 1,
                                    categories: maxes.keys.sorted(by: <).map({repToString($0)}),
                                    selectedCategory: $selectedRepCount,
                                    stringMapping: {$0},
                                    colorMapping: {viewModel.colorByRepCount($0, palette)})
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                            .scrollIndicators(.hidden)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
            
            .task {
                viewModel.load(lifts: lifts)
            }
            .navigationTitle(type.string)
            .tint(type.category.getColor(for: palette))
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for days in 0...50 {
        let lift = Lift(liftType: .benchPress, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
        container.mainContext.insert(lift)

        lift.addSet(5, weight: Double.random(in: 150...250), units: .pounds)
        lift.addSet(10, weight: Double.random(in: 100...200), units: .pounds)
        lift.addSet(15, weight: Double.random(in: 50...150), units: .pounds)
    }
    
    return NavigationStack {
        StatItem(type: .benchPress).modelContainer(container)
    }
}

struct WeightProgressView: View {
    
    var viewModel: ViewModel    
    @State var timeWindow: TimeWindow = .week
    @AppStorage(PALETTE) var palette: Palette = .main
    @Binding var selectedReps: String?
    
    @State var selectedDate: Date?
    @State var selectedWeight: Double?

    
    enum TimeWindow : String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case ninetyDays = "90 Days"
        case year = "Year"
        
        var timeRange: Int {
            let days = switch self {
            case .week:
                7
            case .month:
                30
            case .ninetyDays:
                90
            case .year:
                365
            }
            return 60 * 60 * 24 * days
            
        }
    }
    
    
    @ViewBuilder
    func progressTimeWindowPicker(daysRange: Int) -> some View {
        let validWindows = TimeWindow.allCases.filter({window in
            return daysRange >= window.timeRange
        })
        if validWindows.count > 1 {
            Picker("Time Window", selection: $timeWindow.animation()) {
                ForEach(validWindows, id: \.rawValue) { window in
                    Text(window.rawValue).tag(window)
                }
            }
            .pickerStyle(.segmented)
        } else {
            EmptyView()
        }

    }
    
    var body: some View {
        VStack {
            if case .loaded(_, _, let allTimeMax, let filteredLifts, let daysRange) = viewModel.data {
                progressTimeWindowPicker(daysRange: daysRange)
//                if let date = selectedDate, let weight = selectedWeight {
//                    Text("Selected date: \(date), selectedWeight \(weight)")
//                }

                Chart(filteredLifts) { lift in
                    ForEach(lift.maxes().sorted(by: <), id: \.key) { reps, maximum in
                        PointMark(x: .value("Date", lift.timestamp, unit: .day), y:
                                .value(repToString(reps), maximum))
                        .symbol(.circle)
                        .symbolSize(repToString(reps) == selectedReps ? 100.0 : 40.0)
                        .foregroundStyle(by: .value("Reps", repToString(reps)))
                    }
                }
                .chartForegroundStyleScale(mapping: { data in
                    return viewModel.colorByRepCount(data, palette)
                })
                .chartXSelection(value: $selectedDate)
                .chartYSelection(value: $selectedWeight)
                .chartXAxis {
                    switch timeWindow {
                    case .week:
                        AxisMarks(values: .automatic(minimumStride: 1)) { date in
                            AxisValueLabel(format: .dateTime.day())
                        }
                    case .month:
                        AxisMarks(values: .automatic(minimumStride: 1)) { date in
                            AxisValueLabel(format: .dateTime.week())
                        }
                    case .ninetyDays:
                        AxisMarks(values: .automatic(minimumStride: 1)) { date in
                            AxisValueLabel(format: .dateTime.week())
                        }
                    case .year:
                        AxisMarks(values: .automatic(minimumStride: 1)) { date in
                            AxisValueLabel(format: .dateTime.month())
                        }
                    }
                }
                .chartXVisibleDomain(length: timeWindow.timeRange)
                .chartYScale(domain: 0...allTimeMax * 1.4)
                .chartScrollPosition(initialX: Date().addingTimeInterval(TimeInterval(-1 * timeWindow.timeRange)))
                .chartScrollableAxes(.horizontal)
                .chartScrollTargetBehavior(
                    .valueAligned(matching: .init(day: 0))
                )
                .chartLegend(.hidden)
                .frame(minWidth: 150, minHeight: 200)
            }
        }
    }
}
