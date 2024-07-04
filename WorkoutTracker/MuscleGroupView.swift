//
//  HumanBodyView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/23/24.
//

import SwiftUI
import SwiftData
import Collections

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


enum MuscleLocation {
    case front
    case back
}


struct MuscleView<Selector: MuscleGroupSelector, S: Shape> : View{
    var muscleGroup: MuscleGroup
    var mirrored: Bool = false
    
    var isSelected: Bool {
        selector.selectedMuscleGroup == muscleGroup
    }
    
    var percentage: Double {
        selector.getWeight(muscleGroup, userGeneratedTypes: userGeneratedTypes)
    }
    
    
    @ViewBuilder var shape: S
    @Binding var selector: Selector
    @AppStorage(PALETTE) var palette: Palette = .main
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    
    var body: some View {
        ZStack {
            shape.fill(.black)
            shape
                .fill(.tint.opacity((percentage / 2.0) + 0.50))
                .stroke(Color.white, style: .init(lineWidth: isSelected ? 2.0 : 0.0))
                .onTapGesture {
                    withAnimation {
                        if isSelected {
                            selector.selectedMuscleGroup = nil
                        } else {
                            selector.selectedMuscleGroup = muscleGroup
                        }
                    }
                }
        }
        .rotation3DEffect(.degrees(mirrored ? 180 : 0.0), axis: (x: 0, y: 1, z: 0))
    }
}


protocol MuscleGroupSelector {
    var selectedMuscleGroup: MuscleGroup? { get set }
    func getWeight(_ muscleGroup: MuscleGroup, userGeneratedTypes: [UserGeneratedLiftType]) -> Double
}

@Observable
class MuscleGroupState : MuscleGroupSelector {
    func getWeight(_ muscleGroup: MuscleGroup, userGeneratedTypes: [UserGeneratedLiftType]) -> Double {
        if case .loaded(let stats) = self.stats {
           return stats.normalizedWeight.getWeight(muscleGroup)
        } else {
            return 0.0
        }
        
    }
    
    var selectedMuscleGroup: MuscleGroup? = nil
    
    enum MuscleGroupStats {
        case loading
        case loaded(MuscleGroupStatsData)
    }
    
    // For every lift
    // - Multiply reps * liftWeights vector * recency
    // - Add em up
    // - Have a single vector representing score for each muscle group
    // - Normalize
    struct MuscleGroupStatsData {
        var normalizedWeight: LiftWeights
        var suggestedLifts : [LiftSuggestion]
    }
    
    struct LiftSuggestion : Comparable, Identifiable {
        static func < (lhs: MuscleGroupState.LiftSuggestion, rhs: MuscleGroupState.LiftSuggestion) -> Bool {
            if lhs.score == rhs.score {
                return lhs.type < rhs.type
            } else {
                return lhs.score < rhs.score
            }
        }
        
        var id: String {
            type.id
        }
        
        var score: Double
        var type: LiftType
    }
    
    var stats : MuscleGroupStats = .loading
    func load(lifts: [Lift], userGeneratedTypes: [UserGeneratedLiftType]) {
        let scores = lifts.reduce(into: LiftWeights(), { scores, lift in 
            let weights = lift.getLiftWeights(userGeneratedTypes)
            for (group, weight) in weights.map {
                let totalReps = Double(lift.sets.reduce(0, {sum, liftSet in sum + liftSet.reps}))
                let score = weight * totalReps * lift.recencyFactor
                scores.add(group, score: score)
            }
        })
        let normalized = scores.normalize()

        let allTypes = LiftType.allCases + userGeneratedTypes.map({userType in .other(name: userType.name, category: userType.category, id: userType.id)})
        
        var suggestionHeap = allTypes.reduce(into: Heap<LiftSuggestion>(), { heap, type in
            let score = type.getLiftWeights(userGeneratedTypes).suggestionScore(scores)
//            let score = type.getLiftWeights(userGeneratedTypes).dotProduct(scores)
            
            if heap.count < 5 {
                heap.insert(LiftSuggestion(score: score, type: type))
            } else if let min = heap.min, min.score < score {
                let _ = heap.popMin()
                heap.insert(LiftSuggestion(score: score, type: type))
            }
        })
        
        var suggestions: [LiftSuggestion] = []
        while !suggestionHeap.isEmpty {
            if let max = suggestionHeap.popMax() {
              suggestions.append(max)
            }
        }

        stats = .loaded(MuscleGroupStatsData(normalizedWeight: normalized, suggestedLifts: suggestions))
    }
    
}

struct MuscleGroupFrontView<Selector: MuscleGroupSelector>: View {
    @Binding
    var selector: Selector
    
    var body: some View {
        ZStack {
            Silhouette().fill(.gray)
            MuscleView(muscleGroup: .abs, shape: {Abs()}, selector: $selector)
            MuscleView(muscleGroup: .abs, mirrored: true, shape: {Abs()}, selector: $selector)
            MuscleView(muscleGroup: .calves, shape: {FrontCalf()}, selector: $selector)
            MuscleView(muscleGroup: .calves, mirrored: true, shape: {FrontCalf()}, selector: $selector)
            MuscleView(muscleGroup: .quadriceps, shape: {Quads()}, selector: $selector)
            MuscleView(muscleGroup: .quadriceps, mirrored: true, shape: {Quads()}, selector: $selector)
            MuscleView(muscleGroup: .obliques, shape: {Obliques()}, selector: $selector)
            MuscleView(muscleGroup: .obliques, mirrored: true, shape: {Obliques()}, selector: $selector)
            MuscleView(muscleGroup: .chest, shape: {Chest()}, selector: $selector)
            MuscleView(muscleGroup: .chest, mirrored: true, shape: {Chest()}, selector: $selector)
            MuscleView(muscleGroup: .forearms, shape: {Forearm()}, selector: $selector)
            MuscleView(muscleGroup: .forearms, mirrored: true, shape: {Forearm()}, selector: $selector)
            MuscleView(muscleGroup: .biceps, shape: {Bicep()}, selector: $selector)
            MuscleView(muscleGroup: .biceps, mirrored: true, shape: {Bicep()}, selector: $selector)
            MuscleView(muscleGroup: .deltoid, shape: {Deltoid()}, selector: $selector)
            MuscleView(muscleGroup: .deltoid, mirrored: true, shape: {Deltoid()}, selector: $selector)
        }
        .aspectRatio(66.70126342773438 / 143.2188720703125, contentMode: .fit)
    }
}


struct MuscleGroupBackView<Selector: MuscleGroupSelector>: View {
    @Binding
    var selector: Selector
    
    var body: some View {
        ZStack {
            Silhouette().fill(.gray)
            MuscleView(muscleGroup: .lowerBack, shape: {LowerBack()}, selector: $selector)
            MuscleView(muscleGroup: .deltoid, shape: {RearDeltoid()}, selector: $selector)
            MuscleView(muscleGroup: .deltoid, mirrored: true, shape: {RearDeltoid()}, selector: $selector)
            MuscleView(muscleGroup: .triceps, shape: {Tricep()}, selector: $selector)
            MuscleView(muscleGroup: .triceps, mirrored: true, shape: {Tricep()}, selector: $selector)
            MuscleView(muscleGroup: .forearms, shape: {RearForearm()}, selector: $selector)
            MuscleView(muscleGroup: .forearms, mirrored: true, shape: {RearForearm()}, selector: $selector)
            MuscleView(muscleGroup: .trapezius, shape: {Trapezius()}, selector: $selector)
            MuscleView(muscleGroup: .trapezius, mirrored: true, shape: {Trapezius()}, selector: $selector)
            MuscleView(muscleGroup: .latissmusDorsi, shape: {Lats()}, selector: $selector)
            MuscleView(muscleGroup: .latissmusDorsi, mirrored: true, shape: {Lats()}, selector: $selector)
            MuscleView(muscleGroup: .glutes, shape: {Glute()}, selector: $selector)
            MuscleView(muscleGroup: .glutes, mirrored: true, shape: {Glute()}, selector: $selector)
            MuscleView(muscleGroup: .hamstrings, shape: {Hamstring()}, selector: $selector)
            MuscleView(muscleGroup: .hamstrings, mirrored: true, shape: {Hamstring()}, selector: $selector)
            MuscleView(muscleGroup: .calves, shape: {RearCalf()}, selector: $selector)
            MuscleView(muscleGroup: .calves, mirrored: true, shape: {RearCalf()}, selector: $selector)
        }
        .aspectRatio(66.70126342773438 / 143.2188720703125, contentMode: .fit)
    }
}

struct MuscleGroupView: View {
    @State
    var muscleGroupState = MuscleGroupState()
    
    @State var showInfoSheet = false
    @Query(filter: Lift.lastWeek(), sort: \Lift.timestamp, order: .reverse) var lastWeekLifts: [Lift]
    @Query var userGeneratedTypes: [UserGeneratedLiftType]
    @Environment(\.modelContext) var modelContext
    
    @State var tintColor: Color = .init(hex: .init("06F3FF", radix: 16)!)
    @State var showImpactForLift: Lift? = nil
    
    @AppStorage(PALETTE) var palette: Palette = .main
    
    @ViewBuilder
    func muscles(_ stats: MuscleGroupState.MuscleGroupStatsData) -> some View {
        HStack {
            MuscleGroupFrontView(selector: $muscleGroupState)
            MuscleGroupBackView(selector: $muscleGroupState)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            muscleGroupState.selectedMuscleGroup = nil
        }
    }
    
    @ViewBuilder
    func musclesLabel(_ stats: MuscleGroupState.MuscleGroupStatsData) -> some View {
        let percentage = { if let selected = muscleGroupState.selectedMuscleGroup {
            stats.normalizedWeight.getWeight(selected)
        } else {
            stats.normalizedWeight.mean
        }}()
        HStack {
            if let selected = muscleGroupState.selectedMuscleGroup {
                Text(selected.rawValue)
            } else {
                Text("Overall")
            }
            Spacer()
            Text("\((percentage * 100).clean)%")
        }
        .font(.title3)
        .padding()
        .background(ZStack {
            Rectangle().fill(.black)
            Rectangle().fill(tintColor).opacity((percentage / 2) + 0.5)
        })
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    if case .loaded(let stats) = muscleGroupState.stats {
                        
                        ScrollView(.horizontal) {
                            HStack {
                                VStack(alignment: .center) {
                                    Text("MUSCLE GROUPS")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 15.0)
                                    .padding(.bottom, 10.0)
                                    muscles(stats)
                                    musclesLabel(stats)
                                }
                                .padding()
                                .id("muscles")
                                .background(Color(uiColor: UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .frame(width: UIScreen.screenWidth - (CARD_PADDING * 2))
                                VStack(alignment: .center) {
                                    ScrollView(.vertical) {
                                        Text("SUGGESTED LIFTS")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                        .padding(.leading, 15.0)
                                        .padding(.bottom, 10.0)
                                    
                                        ForEach(stats.suggestedLifts) { suggestion in
                                            HStack {
                                                Text(suggestion.type.string)
                                                Spacer()
//                                                Text(suggestion.score.clean)
                                            }
                                            .font(.title3)
                                            .padding()
                                            .background(suggestion.type.category.getColor(for: palette))
                                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(uiColor: UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .id("suggestions")
                                .frame(width: UIScreen.screenWidth - (CARD_PADDING * 2))
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 20)
                        .scrollIndicators(.hidden)
                        
                        Spacer(minLength: 20.0)
                        
                        VStack {
                            Section {
                                HStack {
                                    Text("CONTRIBUTING LIFTS")
                                    Spacer()
                                }
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .padding(.leading, 15.0)
                                let contributingLifts = lastWeekLifts.filter({$0.getLiftWeights(userGeneratedTypes).affects(muscleGroupState.selectedMuscleGroup)})
                                if contributingLifts.count > 0 {
                                    VStack {
                                        Divider().opacity(0.0)
                                        ForEach(contributingLifts) { lift in
                                            let percentage = {
                                                if let selectedMuscleGroup = muscleGroupState.selectedMuscleGroup {
                                                    return lift.getLiftWeights(userGeneratedTypes).getWeight(selectedMuscleGroup) * lift.recencyFactor
                                                } else {
                                                    return lift.recencyFactor
                                                }
                                            }()
                                            VStack {
                                                HStack {
                                                    Text(lift.type.string)
                                                    Spacer()
                                                    if showImpactForLift == lift {
                                                        Text("\((percentage * 100).clean)%")
                                                    } else {
                                                        Text(lift.timestamp.formatted(Date.FormatStyle().month(.defaultDigits).day()))
                                                    }
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture(perform: {
                                                    withAnimation {
                                                        if showImpactForLift == lift {
                                                            showImpactForLift = nil
                                                        } else {
                                                            showImpactForLift = lift
                                                        }
                                                    }
                                                })
                                                .padding(.horizontal, 15.0)
                                                .padding(.vertical, 10.0)
                                            }
                                            Divider().padding(.leading).opacity(contributingLifts.last == lift ? 0.0 : 1.0)

                                        }

                                    }
                                    .contentShape(Rectangle())
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                }
    
                            }
                            
                        }
                        .padding()
                    } else {
                        ProgressView()
                    }
                }
            }
            .task {
                muscleGroupState.load(lifts: lastWeekLifts, userGeneratedTypes: userGeneratedTypes)
            }
            .environment(muscleGroupState)
            .navigationTitle("Muscle Saturation")
            .toolbar {
                ToolbarItem(placement: .automatic, content: {
                    Button {
                        withAnimation {
                            showInfoSheet.toggle()
                        }
                    } label: {
                        Label("Info", systemImage: showInfoSheet ? "info.circle.fill" : "info.circle").labelStyle(.iconOnly)
                    }
                })
            }
            .sheet(isPresented: $showInfoSheet.animation(), content: {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Info").font(.title)
                        Spacer()
                        Button {
                            showInfoSheet = false
                        } label: {
                            Label("Close", systemImage: "xmark.circle").labelStyle(.titleOnly)
                        }
                    }
                    Spacer()
                    Text("Each lift you perform affects certain muscle groups")
                    Text("This page looks at your last week of lifts to highlight muscle groups that are overworked or underworked.")
                    Text("Older lifts contribute less to muscle saturation.")
                    Text("The suggestions provided are not a substitute for a certified personal trainer. Consult an expert before attempting new lifts.")
                }
                .padding( 20)
                .presentationDetents([.medium])
                
            })
            .tint(tintColor)
        }
    }
}

#Preview("Both") {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
    
    
    for type in [LiftType.benchPress, LiftType.backSquat, LiftType.frontSquat] {
        for days in 0...Int.random(in: 30...70) {
            let lift = Lift(liftType: type, timestamp: Date.now.addingTimeInterval(TimeInterval(-60*60*24*days)),  modifiers: [.incline])
            container.mainContext.insert(lift)
            
            let weight = Double.random(in: 150...250)
            let reps = [5, 10, 15].randomElement()!
            lift.addSet(reps, weight: weight, units: .pounds)
        }
            
    }
    return MuscleGroupView().modelContainer(container)
}

