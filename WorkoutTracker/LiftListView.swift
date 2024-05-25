//
//  LiftListView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

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
    
    @State var expanded: Bool = false
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center)
             {
                Text(liftSet.reps == 1 ? "**1** rep" : "**\(liftSet.reps)** reps")
                Spacer()
                if lift.weighted {
                    Text(try! AttributedString(markdown: "\(liftSet.weight.displayString)"))
                }
                if case .plates(_) = liftSet.weight.data {
                    Image(systemName: "chevron.down").rotationEffect(Angle(degrees: expanded ? 0.0 : -90.0))
                        .imageScale(.small)
                }
            }
            if case let .plates(plates) = liftSet.weight.data, expanded {
                PlatesView(plates: plates, removePlate: {_ in })
            }
        }
        .modifier(AnimatingCellHeight(height: expanded ? 150 : 40))
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
    
    var lift: Lift
    
    var body: some View {
        if lift.sets.isEmpty {
            EmptyView()
        } else {
            HStack
             {
                if lift.allSetsSame() {
                    Text("\(lift.sets.count)x").font(.title)
                    LiftSetView(liftSet: lift.sets.first!, lift: lift)
                        .font(.title3)
                        .padding()
                        .background(Color(uiColor: UIColor.systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                } else {
                    VStack {
                        ForEach(lift.sets) { liftSet in
                            LiftSetView(liftSet: liftSet, lift: lift)
                            if liftSet.id != lift.sets.last?.id {
                                Divider()
                            }
                        }
                    }
                    .font(.title3)
                    .padding()
                    .background(Color(uiColor: UIColor.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
            }
        }
        
    }
}

struct LiftListItem: View {
    @State var lift: Lift
    @Binding var editingLift: Lift?
    @Environment(\.modelContext) private var modelContext
    var scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        VStack {
            HStack {
                Text(lift.type.string)
                    .font(.title)
                Spacer()
                Text("\(lift.timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                
            }
            if lift.modifiers.count > 0 {
                HStack {
                    ForEach(lift.modifiers.sorted(by: {$0.rawValue < $1.rawValue}), id: \.rawValue) { modifier in
                        Text(modifier.rawValue)
                            .padding(10)
                            .background(Color(uiColor: UIColor.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))

                        
                    }
                    Spacer()
                }
            }
            SetsView(lift: lift)
            if !lift.notes.isEmpty {
                HStack {
                    Text(lift.notes)
                        .padding(10)
                    Spacer()
                }.background(Color(uiColor: UIColor.systemGroupedBackground))
            }
        }
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
                                       notes: lift.notes)

                withAnimation {
                    modelContext.insert(newLift)
                }
                withAnimation {
                    scrollViewProxy.scrollTo(0)
                }
            } label: {
                Label("Repeat Now", systemImage: "arrow.circlepath")
            }
        })
        
        .padding([.top, .bottom], 5.0)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24.0))
        .buttonStyle(.plain)
    }
}

struct LiftListView: View {
    @State var searchText: String = ""

    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    
    var allLiftsByCategory: [LiftCategory: [LiftType]] {
        generateAllLiftsByCategory(userGeneratedTypes: userGeneratedTypes)
    }
    
    @State var filterSelection: LiftType? = nil

    @State var editingLift: Lift? = nil
    @State var addingLift: Bool = false
    
    private var liftsByDate: [(TimelessDate, [Lift])] {
        var maybeLastDate : TimelessDate? = nil
        var todayLifts : [Lift] = []
        var output : [(TimelessDate, [Lift])] = []
        
        for lift in lifts{
            if searchText != "" &&
                !lift.type.string.containsIgnoringCase(searchText) &&
                !lift.type.category.rawValue.containsIgnoringCase(searchText) &&
                !lift.notes.containsIgnoringCase(searchText) &&
                !lift.modifiers.contains(where: {$0.rawValue.containsIgnoringCase(searchText)})
                {
                continue
            }
            if let filterType = filterSelection, filterType != lift.type {
                continue
            }
            let currentDate = lift.timestamp.timeless()
            if let lastDate = maybeLastDate {
                if lastDate != currentDate {
                    if !todayLifts.isEmpty {
                        output.append((lastDate, todayLifts.sorted(by: {$0.timestamp > $1.timestamp})))
                    }
                    maybeLastDate = currentDate
                    todayLifts = []
                }
            } else {
                maybeLastDate = currentDate
            }
            todayLifts.append(lift)
            
        }
        
        // Clear out the last chunk
        if let lastDate = maybeLastDate {
            output.append((lastDate, todayLifts.sorted(by: {$0.timestamp > $1.timestamp})))
        }
        return output
    }
    
    var filterImageName: String {
        if let _ = filterSelection {
            return "line.3.horizontal.decrease.circle.fill"
        } else {
            return "line.3.horizontal.decrease.circle"
        }
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    EmptyView().id(0)
                    ForEach(liftsByDate, id: \.0.hashValue) { (date, liftsForDate) in
                        Section("\(date.format())") {
                            ForEach(liftsForDate) { lift in
                                VStack {
                                    LiftListItem(lift: lift, editingLift: $editingLift, scrollViewProxy: proxy)
                                }
                            }
                            .onDelete { indexSet in
                                let liftsToRemove = indexSet.map({idx in liftsForDate[idx]})
                                for lift in liftsToRemove {
                                    modelContext.delete(lift)
                                }
                            }
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
                .sheet(isPresented: $addingLift, content: {
                    AddLiftView(liftType: .benchPress)
                })
                .sheet(item: $editingLift) { lift in
                    AddLiftView(lift: lift)
                }
            }
        }
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
