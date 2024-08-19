//
//  LiftListView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData
import SectionedQuery

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}


struct LiftSetView: View {
    var liftSet: LiftSet
    var lift: Lift
    var rendering: Bool
    
    @State var expanded: Bool = false
    @AppStorage(PALETTE) var palette: Palette = .main
    
    var platesToShow: WeightPlates? {
        if case let .plates(plates) = liftSet.weight.data, expanded || rendering {
            plates
        } else {
            nil
        }
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center)
             {
                Text(liftSet.reps == 1 ? "**1** rep" : "**\(liftSet.reps)** reps")
                Spacer()
                 if lift.weighted {
                     Text(try! AttributedString(markdown: "\(liftSet.weight.displayString)"))
                     if case .plates(_) = liftSet.weight.data, !rendering {
                         Image(systemName: "chevron.down").rotationEffect(Angle(degrees: expanded ? 0.0 : -90.0))
                             .imageScale(.small)
                     }
                 }
            }
            if let plates = platesToShow {
                PlatesView(plates: plates, removePlate: {_ in }, rendering: rendering, accentColor: .white, units: liftSet.weight.units)
            }
        }
        .modifier(AnimatingCellHeight(height: platesToShow != nil ? 150 : 40))
        .onTapGesture {
            if case .plates(_) = liftSet.weight.data {
                withAnimation {
                    expanded.toggle()
                }
            }
        }
    }
}

struct SetsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var lift: Lift
    @AppStorage(PALETTE) var palette: Palette = .main
    var rendering: Bool
    
    
    var body: some View {
        if lift.sets.isEmpty {
            EmptyView()
        } else {
            HStack
             {
                if lift.allSetsSame() {
                    Text("\(lift.sets.count)x").font(.title)
                    LiftSetView(liftSet: lift.sets.first!, lift: lift, rendering: rendering)
                        .font(.title3)
                        .padding()
                        .background(lift.type.category.getColor(for: palette).background(scheme: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                } else {
                    VStack {
                        ForEach(lift.sets) { liftSet in
                            LiftSetView(liftSet: liftSet, lift: lift, rendering: rendering)
                            if liftSet.id != lift.sets.last?.id {
                                Divider()
                            }
                        }
                    }
                    .font(.title3)
                    .padding()
                    .background(lift.type.category.getColor(for: palette).background(scheme: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
            }
        }
        
    }
}

@Observable
class LiftListItemMuscleGroupSelector : MuscleGroupSelector {
    var lift: Lift
    var selectedMuscleGroup: MuscleGroup? = nil
    
    func getWeight(_ muscleGroup: MuscleGroup, userGeneratedTypes: [UserGeneratedLiftType]) -> Double {
        return lift.getLiftWeights(userGeneratedTypes).getWeight(muscleGroup)
    }
    
    init(lift: Lift) {
        self.lift = lift
    }
    
}    

func weightDisplayString(_ weight: Double) -> String {
    return MuscleGroupImpact(weight: weight).rawValue
}

struct LiftMuscleSelectionView: View {
    var weight: Double
    var muscleGroup: MuscleGroup
    
    @AppStorage(PALETTE) var palette: Palette = .main
    var lift: Lift
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(muscleGroup.rawValue)
            Spacer()
            Text(weightDisplayString(weight))
        }
        .font(.title3)
        .padding()
        .background(lift.type.category.getColor(for: palette).background(scheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}

struct LiftMuscleGroupSilhouetteView: View {
    @Binding var selector: LiftListItemMuscleGroupSelector
    var lift: Lift
    @AppStorage(PALETTE) var palette: Palette = .main
    
    var body: some View {
            HStack {
                MuscleGroupFrontView(selector: $selector)
                MuscleGroupBackView(selector: $selector)
            }
            .tint(lift.type.category.getColor(for: palette))
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    selector.selectedMuscleGroup = nil
                }
            }

    }
}

struct LiftMuscleGroupView : View {
    @State var selector: LiftListItemMuscleGroupSelector
    var lift: Lift
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    
    var body: some View {
        VStack {
            LiftMuscleGroupSilhouetteView(selector: $selector, lift: lift)
            if let selected = selector.selectedMuscleGroup {
                Spacer(minLength: 20.0)
                LiftMuscleSelectionView(weight: selector.getWeight(selected, userGeneratedTypes: userGeneratedTypes), muscleGroup: selected, lift: lift)
            }
        }
    }
    
    init(lift: Lift) {
        selector = LiftListItemMuscleGroupSelector(lift: lift)
        self.lift = lift
    }
    
}


struct LiftListItem: View {
    @State var lift: Lift
    @Binding var editingLift: Lift?
    @Binding var showStatsForType: LiftType?
    @Binding var model: ListViewModel
    @AppStorage(PALETTE) var palette: Palette = .main
    
    enum CardState {
        case liftInfo
        case muscleGroups
    }
    @State var cardState : CardState = .liftInfo
    
    var onLiftsScreen: Bool
    
    var scrollViewProxy: ScrollViewProxy
    var onDelete: ((Lift) -> ())?
    
    // init on lift screen
    init(lift: Lift, editingLift: Binding<Lift?>, showStatsForType: Binding<LiftType?>, model: Binding<ListViewModel>, scrollViewProxy: ScrollViewProxy, onDelete: @escaping (Lift) -> ()) {
        onLiftsScreen = true
        self.lift = lift
        _editingLift = editingLift
        _showStatsForType = showStatsForType
        _model = model
        self.scrollViewProxy = scrollViewProxy
        self.onDelete = onDelete
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    var textColor: Color {
        switch colorScheme {
        case .light:
            Color.black
        case .dark:
            Color.white
        @unknown default:
            Color.white
        }
    }
    
    @MainActor 
    func render() -> Image {
        let RENDER_WIDTH = 400.0
        let renderer = ImageRenderer(content: card(rendering: true))
        renderer.scale = 3.0
        renderer.proposedSize = .init(width: RENDER_WIDTH, height: nil)
        return Image(uiImage: renderer.uiImage!)
    }
    
    
    
    @ViewBuilder
    func card(rendering: Bool) -> some View {
        VStack {
            HStack {
                Text(lift.type.string)
                    .font(.title)
                    .foregroundStyle(textColor)
                Spacer()
            }
            if case .muscleGroups = cardState, !rendering {
                LiftMuscleGroupView(lift: lift)
            } else {
                if lift.modifiers.count > 0 {
                    HStack {
                        ForEach(lift.modifiers.sorted(by: {$0.rawValue < $1.rawValue}), id: \.rawValue) { modifier in
                            Text(modifier.rawValue)
                                .padding(10)
                                .background(lift.type.category.getColor(for: palette).background(scheme: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .foregroundStyle(textColor)
                        }
                        Spacer()
                    }
                }
                SetsView(lift: lift, rendering: rendering)
                    .foregroundStyle(textColor)
                if !lift.notes.isEmpty {
                    HStack {
                        Text(lift.notes)
                            .foregroundStyle(textColor)
                            .padding(10)
                        Spacer()
                    }
                    .background(lift.type.category.getColor(for: palette).background(scheme: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    
                }
            }
            Spacer(minLength: 10.0)
            HStack(alignment: .bottom) {
                Text("\(lift.timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(textColor)
                Spacer()
                if !rendering {
                    let showMuscleGroups = cardState == .muscleGroups
                    Label(showMuscleGroups ? "Show Muscle Groups" : "Show Lift Info", systemImage: showMuscleGroups ? "figure.child.circle.fill" : "figure.child.circle").labelStyle(.iconOnly)
                } else {
                    HStack {
                        Text("Planetary Lifts")
                            .foregroundStyle(textColor)
                            .font(.caption)
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    }
                }
            }.onTapGesture {
                withAnimation {
                    cardState = switch cardState {
                    case .liftInfo:
                            .muscleGroups
                    case .muscleGroups:
                            .liftInfo
                    }
                }
                
            }

        }
        .padding()
        .background(lift.type.category.getColor(for: palette))
        .clipShape(RoundedRectangle(cornerRadius: 24.0, style: rendering ? .circular : .continuous))
        .buttonStyle(.plain)
    }
    
    var body: some View {
        card(rendering: false)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24.0, style: .continuous))
        .contextMenu(menuItems: {
            if onLiftsScreen {
                Button {
                    editingLift = lift
                } label: {
                    Label("Edit Lift", systemImage: "pencil")
                }
            }
            Button {
                let newLift = Lift(liftType: lift.type,
                                   sets: lift.sets,
                                   timestamp: Date.now,
                                   modifiers:
                                    lift.modifiers,
                                   notes: lift.notes,
                                   weighted: lift.weighted)
                
                Task {
                    modelContext.insert(newLift)
                    model.load()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + SCROLL_DELAY) {
                        withAnimation {
                            scrollViewProxy.scrollTo(Date.now.timeless())

                        }
                    }
                }
                
            } label: {
                Label("Repeat Now", systemImage: "arrow.circlepath")
            }
            Button {
                showStatsForType = lift.type
            } label: {
                Label("Stats", systemImage: "chart.dots.scatter")
            }
            ShareLink("Share", item: render(), preview: SharePreview(lift.type.string, image: render()))
            if let delete = onDelete {
                Button(role: .destructive) {
                    delete(lift)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        })
    }
}

enum TabType {
    case liftList
    case stats
    case addLift
    case muscles
    case settings
}

struct LiftListView: View {

    
    @State var model: ListViewModel
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let model = ListViewModel(modelContext: modelContext)
        _model = State(initialValue: model)
    }
    
    @State var searchText: String = ""
    @State var filterSelection: LiftType? = nil

    @State var editingLift: Lift? = nil
    @State var addingLift: Bool = false
    @State var showStatsForType: LiftType? = nil
    @State var selectedTab: TabType = .liftList
    @State var previousTab: TabType = .liftList

    @AppStorage(PALETTE) var palette : Palette = .main
    @AppStorage(UNREAD_LIFTS) var unreadLifts: Int = 0
    
    
    func getTintColor() -> Color {
        if let mostRecentLift = model.getMostRecentLiftType() {
            return mostRecentLift.category.getColor(for: palette)
        }
        return LiftCategory.allCases.first!.getColor(for: palette)
    }
    
    func filterLifts(_ lifts: [Lift]) -> [Lift] {
        lifts.filter({ lift in
            let passesSearch = searchText == "" ||
                lift.type.string.containsIgnoringCase(searchText) ||
                lift.type.category.rawValue.containsIgnoringCase(searchText) ||
                lift.notes.containsIgnoringCase(searchText) ||
                lift.modifiers.contains(where: {$0.rawValue.containsIgnoringCase(searchText)})
            
            let passesFilter = filterSelection == nil || filterSelection == lift.type
            return passesSearch && passesFilter
        })

    }

    var filterImageName: String {
        if let _ = filterSelection {
            return "line.3.horizontal.decrease.circle.fill"
        } else {
            return "line.3.horizontal.decrease.circle"
        }
    }
    

    @ViewBuilder
    var filterButton: some View {
        if let _ = filterSelection {
            Button(role: .destructive, action: {
                withAnimation {
                    filterSelection = nil
                }
            }) {
                Label("Cancel Filter", systemImage: filterImageName)
            }
        } else if let data = model.loadedData, data.presentTypesByCategory.count > 0  {
                Menu("Filter", systemImage: filterImageName, content: {
                    ForEach(data.presentTypesByCategory.keys.sorted(by: <), id: \.rawValue) { category in
                        Menu(category.rawValue, content: {
                            ForEach(data.presentTypesByCategory[category]!, id: \.hashValue) { lift in
                                Button {
                                    withAnimation {
                                        filterSelection = lift
                                    }
                                } label: {
                                    Text(lift.string)
                                }
                            }
                        })
                        
                    }
                })
        } else {
           EmptyView()
        }

    }
    
    @ViewBuilder
    var overlay: some View {
        if let data = model.loadedData, data.liftsByDate.count == 0 {
            HStack {
                Spacer()
                Text("Press ")
                Button {
                    addingLift = true
                } label: {
                    Label("Add Lift", systemImage: "plus").labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .padding(10)
                Text(" to create your first lift!")
                Spacer()
            }
        }
    }
    
    
    @ViewBuilder
    func liftSection(section: (TimelessDate, [Lift]), proxy: ScrollViewProxy) -> some View {
        let liftsForDate = section.1
        let date = section.0
        let filteredLifts = filterLifts(liftsForDate)
        if !filteredLifts.isEmpty {
            VStack {
                HStack {
                    Text("\(date.format())".uppercased())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(filteredLifts.first!.type.category.getColor(for: palette))
                    Spacer()
                }.padding([.horizontal], 20)

                ForEach(filteredLifts) {lift in
                    LiftListItem(lift: lift,
                                 editingLift: $editingLift,
                                 showStatsForType: $showStatsForType,
                                 model: $model,
                                 scrollViewProxy: proxy,
                                 onDelete: { lift in
                        modelContext.delete(lift)
                        model.load()
                    })
                }
                Spacer(minLength: 40.0)
            }                    
            .id(date)
        }
    }
    
    @MainActor
    @ViewBuilder
    var liftListView: some View {
        NavigationStack {
            ScrollView {
                ScrollViewReader { proxy in
                    HStack {
                        Spacer()
                        LazyVStack {
                            EmptyView().id(TOP_OF_LIST)
                            if let data = model.loadedData {
                                ForEach(data.liftsByDate, id: \.0) { section in
                                    liftSection(section: section, proxy: proxy)
                                }
                            }
                        }
                        .frame(maxWidth: 500.0)
                        .scrollTargetLayout()
                        Spacer()
                    }
                    .sheet(item: $showStatsForType) { type in
                        StatItem(type: type, modelContext: modelContext)
                    }
                    .sheet(item: $editingLift) { lift in
                        AddLiftView(lift: lift, onSave: { _ in
                            model.load()
                        })
                    }
                    .sheet(isPresented: $addingLift, content: {
                        AddLiftView(liftType: model.getMostRecentLiftType() ?? .benchPress, updateUnreadLifts: selectedTab != .liftList, onSave: { newLift in
                            Task {
                                model.load()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + SCROLL_DELAY) {
                                    withAnimation {
                                        proxy.scrollTo(Date.now.timeless())

                                    }
                                }
                            }
                        })
                    })
                    .padding([.horizontal], 20)
                }
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.bottom, 40.0)
            .overlay {
                overlay
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle("Lifts")
            .toolbar() {
                ToolbarItemGroup(placement: .topBarLeading, content: {
                    filterButton
                })
                ToolbarItemGroup(placement: .topBarTrailing, content: {

                    if let _ = model.loadedData {
                        Button {
                            addingLift = true
                        } label: {
                            Label("Add Lift", systemImage: "plus").labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                        .padding(10)
                    }

                })
            }

            .task {
                model.load()
            }
            .onAppear {
                withAnimation {
                    unreadLifts = 0
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))

        }
    }
    

    var body: some View {
        TabView(selection: $selectedTab) {
            liftListView
            .tabItem {
                Label("Lifts", systemImage: "dumbbell")
            }
            .tag(TabType.liftList)
            .badge(unreadLifts)
            StatsView(modelContext: modelContext)
                .tabItem {
                Label("Stats", systemImage: "chart.xyaxis.line")
            }
            .tag(TabType.stats)
            MuscleGroupView(modelContext: modelContext)
                .tabItem {
                Label("Muscles", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(TabType.muscles)

            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(TabType.settings)
        }
        .tint(getTintColor())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline, .narrowGrip], notes: "Notes notes notes notes notes notes notes")
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))

    let secondLift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*10))
    container.mainContext.insert(secondLift)
    secondLift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 250.0, units: .pounds))
    
    
    let yesterday = Date.now.addingTimeInterval(-60*60*24 - 10*60)
    
    let thirdLift = Lift(liftType: .backSquat, timestamp: yesterday)
    container.mainContext.insert(thirdLift)
    thirdLift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 250.0, units: .pounds))
    
    let fourthLift = Lift(liftType: .bicepCurl, timestamp: yesterday.addingTimeInterval(-10.0))
    container.mainContext.insert(fourthLift)
    fourthLift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 80.0, units: .pounds))


    return ContentView()
        .modelContainer(container)
}
#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}

#Preview("Custom Type") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let userType = UserGeneratedLiftType(name: "Custom Type", category: .other, weights: [(.abs, 1.0)])
    
    container.mainContext.insert(userType)
    
    
    let lift = Lift(liftType: .other(name: userType.name, category: userType.category, id: userType.id), timestamp: Date.now, modifiers: [], notes: "Notes notes notes notes notes notes notes")
    container.mainContext.insert(lift)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    

    

    return ContentView()
        .modelContainer(container)
}



#Preview("Screenshots") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    var lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline, .narrowGrip], notes: "Notes notes notes notes notes notes notes")
//    container.mainContext.insert(lift)
//    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))
//    
//    lift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*10))
//    container.mainContext.insert(lift)
//    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 250.0, units: .pounds))
//    
//    lift = Lift(liftType: .deadlift, timestamp: Date.now.addingTimeInterval(-60*10))
//    container.mainContext.insert(lift)
//    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))
//    
    
    
    let yesterday = Date.now.addingTimeInterval(-60*60*24 - 10*60)
    
    lift = Lift(liftType: .backSquat, timestamp: yesterday)
    container.mainContext.insert(lift)
    lift .addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 250.0, units: .pounds))
    
    lift = Lift(liftType: .bicepCurl, timestamp: yesterday)
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 80.0, units: .pounds))
    
    let threeDaysAgo = Date.now.addingTimeInterval(-60*60*24*2)
    lift = Lift(liftType: .frontSquat, timestamp: threeDaysAgo)
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds))

    lift = Lift(liftType: .tricepExtensions, timestamp: threeDaysAgo)
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 80.0, units: .pounds))

    lift = Lift(liftType: .backSquat, timestamp: threeDaysAgo)
    container.mainContext.insert(lift)
    lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: 200.0, units: .pounds))
    
    let lifts : [LiftType] = [.benchPress, .tricepExtensions, .bicepCurl, .backSquat, .deadlift]
    
    for day in 5 ..< 120 {
        lift = Lift(liftType: lifts[day % lifts.count], timestamp: Date.now.addingTimeInterval(TimeInterval(-60 * 60 * 24 * day)))
        container.mainContext.insert(lift)
        lift.addRepeatedSet(times: 3, liftSet: LiftSet(reps: 10, weight: Double(150.0 - 10 * Double(day / 20)), units: .pounds))
    }
    
    return ContentView()
        .modelContainer(container)
}
