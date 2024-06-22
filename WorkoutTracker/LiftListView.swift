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
                PlatesView(plates: plates, removePlate: {_ in }, rendering: rendering, accentColor: .white)
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


struct LiftListItem: View {
    @State var lift: Lift
    @Binding var editingLift: Lift?
    @Binding var showStatsForType: LiftType?
    @AppStorage(PALETTE) var palette: Palette = .main

    var scrollViewProxy: ScrollViewProxy
    var onDelete: (Lift) -> ()
        
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
                Text("\(lift.timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(textColor)

            }
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
        .padding([.top, .bottom], 5.0)
        .padding()
        .background(lift.type.category.getColor(for: palette))
        .clipShape(RoundedRectangle(cornerRadius: 24.0, style: rendering ? .circular : .continuous))
        .buttonStyle(.plain)
        
    }
    var body: some View {
        card(rendering: false)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24.0, style: .continuous))
        .contextMenu(menuItems: {
            Button {
                editingLift = lift
            } label: {
                Label("Edit Lift", systemImage: "pencil")
            }
            Button {                    
                let newLift = Lift(liftType: lift.type,
                                       sets: lift.sets,
                                       timestamp: Date.now,
                                       modifiers:
                                        lift.modifiers,
                                       notes: lift.notes,
                                   weighted: lift.weighted)

                withAnimation {
                    modelContext.insert(newLift)
                }
                withAnimation {
                    scrollViewProxy.scrollTo("Top of List")
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
            Button(role: .destructive) {
                onDelete(lift)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        })
    }
}

struct LiftListView: View {
    @State var searchText: String = ""

    @Environment(\.modelContext) private var modelContext
    
    @SectionedQuery(\.date, sort: [SortDescriptor(\.timestamp, order: .reverse)]) var liftsByDate: SectionedResults<TimelessDate, Lift>
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    
    var allLiftsByCategory: [LiftCategory: [LiftType]] {
        generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes)
    }
    
    @State var filterSelection: LiftType? = nil

    @State var editingLift: Lift? = nil
    @State var addingLift: Bool = false
    @State var showStatsForType: LiftType? = nil
    
    @AppStorage(PALETTE) var palette : Palette = .main
    
    var filterImageName: String {
        if let _ = filterSelection {
            return "line.3.horizontal.decrease.circle.fill"
        } else {
            return "line.3.horizontal.decrease.circle"
        }
    }
    
    func getMostRecentLiftType() -> LiftType? {
        return liftsByDate.first?.first?.type
    }
    
    func getTintColor() -> Color {
        if let mostRecentLift = getMostRecentLiftType() {
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

    
    var body: some View {
        TabView {
            NavigationStack {
                ScrollViewReader { proxy in
                    List {
                        EmptyView().id("Top of List")
                        ForEach(liftsByDate) { section in
                            let liftsForDate = section.elements
                            let date = section.id
                            let filteredLifts = filterLifts(liftsForDate)
                            if !filteredLifts.isEmpty {
                                Section(content: {
                                    ForEach(filteredLifts) {lift in
                                        LiftListItem(lift: lift, editingLift: $editingLift, showStatsForType: $showStatsForType, scrollViewProxy: proxy, onDelete: {modelContext.delete($0)})
                                            .padding([.bottom], 10)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                                }, header: {
                                    HStack {
                                        Text("\(date.format())".uppercased())
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(liftsForDate.first!.type.category.getColor(for: palette))
                                        Spacer()
                                    }
                                })
                            }
                        }
                    }
                    .navigationTitle("Lifts")
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .toolbar() {
                        ToolbarItemGroup(placement: .primaryAction, content: {
                            Button {
                                addingLift = true
                            } label: {
                                Label("Add Lift", systemImage: "plus")
                            }
                            Menu("Filter", systemImage: filterImageName, content: {
                                if let filterType = filterSelection {
                                    Text ("Filtering \(filterType.string) Lifts")
                                    Button(role: .destructive, action: {
                                        filterSelection = nil
                                    }) {
                                        HStack {
                                            Text("Clear Filter")
                                            Image(systemName: "xmark.circle")
                                        }
                                    }
                                } else {
                                    ForEach(allLiftsByCategory.keys.sorted(by: <), id: \.rawValue) { category in
                                        Menu(category.rawValue, content: {
                                            ForEach(allLiftsByCategory[category]!, id: \.hashValue) { lift in
                                                Button {
                                                    filterSelection = lift
                                                } label: {
                                                    Text(lift.string)
                                                }
                                            }
                                        })
                                        
                                    }
                                }
                            })
                        })
                    }
                    .sheet(item: $showStatsForType) { type in
                        StatItem(type: type)
                    }
                    .sheet(isPresented: $addingLift, content: {
                        AddLiftView(liftType: getMostRecentLiftType() ?? .benchPress)
                    })
                    .sheet(item: $editingLift) { lift in
                        AddLiftView(lift: lift)
                    }
                }
            }.tabItem {
                Label("Lifts", systemImage: "dumbbell")
            }
            StatsView().tabItem {
                Label("Stats", systemImage: "chart.xyaxis.line")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }

        }
        .tint(getTintColor())

    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    let lift = Lift(liftType: .benchPress, timestamp: Date.now, modifiers: [.incline, .narrowGrip], notes: "Notes notes notes notes notes notes notes")
    container.mainContext.insert(lift)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
    

    let secondLift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*10))
    container.mainContext.insert(secondLift)
    secondLift.addSet(10, weight: 250.0, units: .pounds)
    secondLift.addSet(10, weight: 250.0, units: .pounds)
    secondLift.addSet(10, weight: 250.0, units: .pounds)
    
    
    let thirdLift = Lift(liftType: .backSquat, timestamp: Date.now.addingTimeInterval(-60*60*24 - 10*60))
    container.mainContext.insert(thirdLift)
    thirdLift.addSet(10, weight: 250.0, units: .pounds)
    thirdLift.addSet(10, weight: 250.0, units: .pounds)
    thirdLift.addSet(10, weight: 250.0, units: .pounds)
    

    return LiftListView()
        .modelContainer(container)
}
