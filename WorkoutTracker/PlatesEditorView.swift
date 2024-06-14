//
//  PlatesEditorView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/13/24.
//

import SwiftUI
import SwiftData

struct PlatesView: View {
    let rectangleSizes = [2.5: CGSize(width: 35.0, height: 35.0),
                          5.0: CGSize(width: 35.0, height: 50.0),
                          10.0: CGSize(width: 35.0, height: 65.0),
                          15.0: CGSize(width: 35.0, height: 80.0),
                          25.0: CGSize(width: 35.0, height: 100.0),
                          35.0: CGSize(width: 45.0, height: 100.0),
                          45.0: CGSize(width: 55.0, height: 100.0),
                          55.0: CGSize(width: 65.0, height: 100.0)
    ]
    
    var plates: WeightPlates
    var removePlate: (UUID) -> ()
    var rendering: Bool

    var innerView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5.0)
                .fill(.gray)
                .frame(minWidth: 100.0, minHeight: 10.0, maxHeight: 10.0)
            HStack(spacing: 5.0) {
                Rectangle().frame(width: 10.0, height: 100.0).opacity(0.0)
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(.gray)
                    .frame(width: 10.0, height: 30.0)
                ForEach(plates.plates) { plate in
                    ZStack {
                        RoundedRectangle(cornerRadius: rectangleSizes[plate.weight]!.width / 4.0)
                            .stroke(Color(uiColor: UIColor.label), lineWidth: 2.0)
                            .fill(Color(uiColor: UIColor.systemBackground))
                            .frame(width:  rectangleSizes[plate.weight]!.width, height: rectangleSizes[plate.weight]!.height)
                        Text("\(plate.weight.clean)")
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
    
    var units: WeightUnits = .pounds
    
    var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.zeroSymbol = ""
            return formatter
    }
    
    let topRowWeights = [2.5, 5.0, 10.0, 15.0]
    let bottomRowWeights =  [25.0, 35.0, 45.0, 55.0]
    
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Total Weight:")
                Spacer()
                Text(plates.weight == 1.0 ? "**1** \(units.singleUnit)" : "**\(plates.weight.clean)** \(units.singleUnit)s")
            }
            PlatesView(plates: plates, removePlate: removePlate, rendering: false)
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
                
            })
                    .environmentObject(editState)
        }
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
