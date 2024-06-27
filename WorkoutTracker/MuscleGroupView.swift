//
//  HumanBodyView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/23/24.
//

import SwiftUI
import SwiftData

enum MuscleLocation {
    case front
    case back
}


struct MuscleView<S: Shape> : View{
    var muscleGroup: MuscleGroup
    var mirrored: Bool = false
    
    var isSelected: Bool {
        muscleGroupState.selectedMuscleGroup == muscleGroup
    }
    
    var percentage: Double {
        if case .loaded(let stats) = muscleGroupState.stats {
            return stats.normalizedWeight.getWeight(muscleGroup)
        } else {
            return 0.0
        }
    }
    
    
    @ViewBuilder var shape: S
    @Environment(MuscleGroupState.self) var muscleGroupState: MuscleGroupState
    @AppStorage(PALETTE) var palette: Palette = .main
    
    var body: some View {
        ZStack {
            shape.fill(.black)
            shape
                .fill(.tint.opacity((percentage / 2.0) + 0.50))
                .stroke(Color.white, style: .init(lineWidth: isSelected ? 2.0 : 0.0))
                .onTapGesture {
                    withAnimation {
                        if isSelected {
                            muscleGroupState.selectedMuscleGroup = nil
                        } else {
                            muscleGroupState.selectedMuscleGroup = muscleGroup
                        }
                    }
                }
        }
        .rotation3DEffect(.degrees(mirrored ? 180 : 0.0), axis: (x: 0, y: 1, z: 0))
    }
}

@Observable
class MuscleGroupState {
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
    }
    
    var stats : MuscleGroupStats = .loading
    func load(lifts: [Lift]) {
        let scores = lifts.reduce(into: LiftWeights(), { scores, lift in
            let weights = lift.getLiftWeights()
            for (group, weight) in weights.map {
                let totalReps = Double(lift.sets.reduce(0, {sum, liftSet in sum + liftSet.reps}))
                let daysSince = Date().timeIntervalSince(lift.timestamp) / (60 * 60 * 24)
                let recencyFactor = (-1.0 / 7.0) * daysSince + 1.0
                let score = weight * totalReps * recencyFactor
                scores.add(group, score: score)
            }
        })
        
        stats = .loaded(MuscleGroupStatsData(normalizedWeight: scores.normalize()))
    }
}

struct MuscleGroupFrontView: View {
    
    var body: some View {
        ZStack {
            Silhouette().fill(.gray)
            MuscleView(muscleGroup: .abs, shape: {Abs()})
            MuscleView(muscleGroup: .abs, mirrored: true, shape: {Abs()})
            MuscleView(muscleGroup: .calves, shape: {FrontCalf()})
            MuscleView(muscleGroup: .calves, mirrored: true, shape: {FrontCalf()})
            MuscleView(muscleGroup: .quadriceps, shape: {Quads()})
            MuscleView(muscleGroup: .quadriceps, mirrored: true, shape: {Quads()})
            MuscleView(muscleGroup: .obliques, shape: {Obliques()})
            MuscleView(muscleGroup: .obliques, mirrored: true, shape: {Obliques()})
            MuscleView(muscleGroup: .chest, shape: {Chest()})
            MuscleView(muscleGroup: .chest, mirrored: true, shape: {Chest()})
            MuscleView(muscleGroup: .forearms, shape: {Forearm()})
            MuscleView(muscleGroup: .forearms, mirrored: true, shape: {Forearm()})
            MuscleView(muscleGroup: .biceps, shape: {Bicep()})
            MuscleView(muscleGroup: .biceps, mirrored: true, shape: {Bicep()})
            MuscleView(muscleGroup: .deltoid, shape: {Deltoid()})
            MuscleView(muscleGroup: .deltoid, mirrored: true, shape: {Deltoid()})
        }
        .aspectRatio(66.70126342773438 / 143.2188720703125, contentMode: .fit)
    }
}


struct MuscleGroupBackView: View {
    
    
    var body: some View {
        ZStack {
            Silhouette().fill(.gray)
            MuscleView(muscleGroup: .lowerBack, shape: {LowerBack()})
            MuscleView(muscleGroup: .deltoid, shape: {RearDeltoid()})
            MuscleView(muscleGroup: .deltoid, mirrored: true, shape: {RearDeltoid()})
            MuscleView(muscleGroup: .triceps, shape: {Tricep()})
            MuscleView(muscleGroup: .triceps, mirrored: true, shape: {Tricep()})
            MuscleView(muscleGroup: .forearms, shape: {RearForearm()})
            MuscleView(muscleGroup: .forearms, mirrored: true, shape: {RearForearm()})
            MuscleView(muscleGroup: .trapezius, shape: {Trapezius()})
            MuscleView(muscleGroup: .trapezius, mirrored: true, shape: {Trapezius()})
            MuscleView(muscleGroup: .latissmusDorsi, shape: {Lats()})
            MuscleView(muscleGroup: .latissmusDorsi, mirrored: true, shape: {Lats()})
            MuscleView(muscleGroup: .glutes, shape: {Glute()})
            MuscleView(muscleGroup: .glutes, mirrored: true, shape: {Glute()})
            MuscleView(muscleGroup: .hamstrings, shape: {Hamstring()})
            MuscleView(muscleGroup: .hamstrings, mirrored: true, shape: {Hamstring()})
            MuscleView(muscleGroup: .calves, shape: {RearCalf()})
            MuscleView(muscleGroup: .calves, mirrored: true, shape: {RearCalf()})
        }
        .aspectRatio(66.70126342773438 / 143.2188720703125, contentMode: .fit)
    }
}

struct MuscleGroupView: View {
    @State
    var muscleGroupState = MuscleGroupState()
    
    @State var showInfoSheet = false
    
    
    @Query(filter: Lift.lastWeek(), sort: \Lift.timestamp, order: .reverse) var lastWeekLifts: [Lift]
    @Environment(\.modelContext) var modelContext
    
    @State var tintColor: Color = .init(hex: .init("06F3FF", radix: 16)!)
    
    var label: some View {
        HStack {
            Text(muscleGroupState.selectedMuscleGroup.map({$0.rawValue}) ?? "Overall")
            Spacer()
            if case .loaded(let stats) = muscleGroupState.stats {
                if let selected = muscleGroupState.selectedMuscleGroup {
                    Text("\((stats.normalizedWeight.getWeight(selected) * 100).clean)%")
                } else {
                    Text("\((stats.normalizedWeight.mean * 100).clean)%")
                }
            } else {
                ProgressView()
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        MuscleGroupFrontView()
                        MuscleGroupBackView()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        muscleGroupState.selectedMuscleGroup = nil
                    }
                    label
                }
                #if DEBUG
                ColorPicker(selection: $tintColor, supportsOpacity: false, label: {
                    Text("Color")
                })
                
                #endif
                Section("Lifts") {
                    ForEach(lastWeekLifts) { lift in
                        let liftWeights = lift.getLiftWeights()
                        if liftWeights.affects(muscleGroupState.selectedMuscleGroup) {
                            HStack {
                                Text(lift.type.string)
                                Spacer()
                                Text(lift.timestamp.timeless().format())
                            }
                        }
                    }
                }
                
                
            }
            .task {
                muscleGroupState.load(lifts: lastWeekLifts)
            }
            .environment(muscleGroupState)
            .navigationTitle("Muscle Saturation")
            .toolbar {
                ToolbarItem(placement: .automatic, content: {
                    Button {
                        showInfoSheet.toggle()
                    } label: {
                        Label("Info", systemImage: showInfoSheet ? "info.circle.filled" : "info.circle")
                    }
                })
            }
            .sheet(isPresented: $showInfoSheet, content: {
                NavigationStack {
                    VStack {
                        Text("Each lift you perform affects certain muscle groups.")
                        Text("This page looks at your last week of lifts to highlight muscle groups that are overworked or underworked.")
                        
                    }
                    .padding()
                    .navigationTitle("Info")
                }
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
            
            for _ in 0...Int.random(in: 1...5) {
                let reps = [5, 10, 15].randomElement()!
                lift.addSet(reps, weight: Double.random(in: 150...250), units: .pounds)
                lift.addSet(reps, weight: Double.random(in: 100...200), units: .pounds)
            }
        }
            
    }
    return MuscleGroupView().modelContainer(container)
}

