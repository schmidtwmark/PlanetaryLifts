//
//  PlatesEditorView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/13/24.
//

import SwiftUI
import SwiftData

struct PlatesView: View {
    let rectangleSizes = [2.5: CGSize(width: 30.0, height: 35.0),
                          5.0: CGSize(width: 30.0, height: 50.0),
                          10.0: CGSize(width: 30.0, height: 65.0),
                          15.0: CGSize(width: 30.0, height: 80.0),
                          25.0: CGSize(width: 30.0, height: 100.0),
                          35.0: CGSize(width: 35.0, height: 100.0),
                          45.0: CGSize(width: 40.0, height: 100.0),
                          55.0: CGSize(width: 45.0, height: 100.0)
    ]
    
    @Environment(\.colorScheme) private var colorScheme

    
    var plates: WeightPlates
    var removePlate: (UUID) -> ()
    var rendering: Bool
    var accentColor: Color
    
    let BAR_CORNER_RADIUS = 3.0
    let BAR_COLOR = Color.gray.lighter(by: 10.0)
    
    let WEIGHT_CORNER_RATIO = 8.0
    var weightColor: Color {
        switch colorScheme {
        case .light:
            Color.gray.lighter(by: 30.0)
        case .dark:
            Color.gray.darker(by: 30.0)
        @unknown default:
            Color.gray.darker(by: 30.0)
        }
    }
    let WEIGHT_STROKE = 4.0
    

    var innerView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: BAR_CORNER_RADIUS)
                .fill(BAR_COLOR)
                .frame(minWidth: 100.0, minHeight: 10.0, maxHeight: 10.0)
            HStack(spacing: 8.0) {
                Rectangle().frame(width: 10.0, height: 100.0).opacity(0.0)
                RoundedRectangle(cornerRadius: BAR_CORNER_RADIUS)
                    .fill(BAR_COLOR)
                    .frame(width: 10.0, height: 30.0)
                ForEach(plates.plates) { plate in
                    ZStack {
                        RoundedRectangle(cornerRadius: rectangleSizes[plate.weight]!.width / WEIGHT_CORNER_RATIO)
                            .stroke(accentColor, lineWidth: WEIGHT_STROKE)
                            .fill(weightColor)
                            .frame(width:  rectangleSizes[plate.weight]!.width, height: rectangleSizes[plate.weight]!.height)
                        Text("\(plate.weight.clean)").font(.footnote).foregroundStyle(.white)
                    }.onTapGesture {
                        withAnimation {
                            removePlate(plate.id)
                        }
                    }
                }
                Spacer()
            }.padding(2.0)
        }
    }

    
    var body: some View {
        if rendering {
           innerView
        } else {
            ScrollView(.horizontal) {
                innerView
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
        }
    }
        
}

struct PlatesEditorView: View {
    @Binding var plates: WeightPlates
    
    var removePlate: (UUID) -> ()
    var addPlate: (Double) -> ()
    var accentColor: Color
    
    var units: WeightUnits = .pounds
    
    var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.zeroSymbol = ""
            return formatter
    }
    
    var topRowWeights: [Double] {
        switch units {
        case .pounds: [2.5, 5.0, 10.0, 15.0]
        case .kilograms: [1.1, 2.3, 4.5, 6.8]
        }
    }
    
    var bottomRowWeights: [Double] {
        switch units {
        case .pounds: [25.0, 35.0, 45.0, 55.0]
        case .kilograms: [11.3, 15.9, 20.4, 25.0]
        }

    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Total Weight:")
                Spacer()
                Text(plates.weight == 1.0 ? "**1** \(units.singleUnit)" : "**\(plates.weight.clean)** \(units.singleUnit)s")
            }
            PlatesView(plates: plates, removePlate: removePlate, rendering: false, accentColor: accentColor)
            HStack {
                Spacer()
                VStack {
                    ForEach([topRowWeights, bottomRowWeights], id: \.first!) { weights in
                        HStack {
                            ForEach(weights, id: \.self) { plateWeight in
                                Button {
                                    withAnimation {
                                        addPlate(plateWeight)
                                    }
                                } label: {
                                    Text("\(plateWeight.clean)")
                                }.buttonStyle(StepperButtonStyle(frame: CGSize(width: 60.0, height: 40.0)))
                            }
                        }
                        
                    }
                }
                Spacer()
            }
            HStack {
                Text("Base Weight")
                Spacer()
                NumberIncrementor(number: $plates.barWeight,  toString: {  "\($0.clean)"},
                                  onIncrement: {return roundedIncrement($0)},
                                  onDecrement: {return max(1.0, roundedDecrement($0))}, frame: CGSize(width: 70, height: 35), formatter: formatter)
            }
            Toggle("Mirrored", isOn: $plates.mirrored)
        }
    }
}


struct PlatesEditorContainer: View {
    @State var plates: WeightPlates = WeightPlates(barWeight: 45.0, plates: [])
    var id = UUID()
    @StateObject var editState: EditState = EditState()

    var body: some View {
        NavigationStack {
            PlatesEditorView(plates: $plates, removePlate: { removeId in
                    plates.plates.removeAll(where: {$0.id == removeId})
            }, addPlate: {plateWeight  in
                    print("Adding plate: \(plates.plates.count)")
                    plates.plates.append(WeightPlates.Plate(weight: plateWeight))
                    print("After add plate: \(plates.plates.count)")
                    plates.plates.sort { $0 > $1 }
                    print("Added plates: \(plates.plates.count)")
                
            }, accentColor: Color.green
            ).environmentObject(editState)
        }.tint(Color.green)
    }
}

#Preview {
    
    PlatesEditorContainer()
}
//
//struct LiftSetEditorContainer: View {
//    
//    @Query
//    var lifts: [Lift]
//    
//    var body: some View {
//        ForEach($lifts, id: \.id) { $lift in
//            Text("Lift")
////            ForEach(lift., id: \.id) { liftSet in       switch liftSet.weight.data {
////                case .plates(let plates):
////                    PlatesEditorView(plates: Binding(get: {return plates}, set: { liftSet.weight.data = .plates($0)
////                    }))
////                default: EmptyView()
////                }
////            }
//        }
//    }
//}
//#Preview("Plates Edit") {
//    
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Lift.self, UserGeneratedLiftType.self, configurations: config)
//    
//    let lift = Lift(liftType: .benchPress, timestamp: Date.now)
//    container.mainContext.insert(lift)
//    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
//    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
//    lift.addSet(10, plates: WeightPlates(barWeight: 45.0, plates: [WeightPlates.Plate(weight: 45.0)]), units: .pounds)
//
//    return NavigationStack {
//        AddLiftView(lift: lift)
//            .modelContainer(container)
//    }
//    
//}
