//
//  PlatesEditorView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/13/24.
//

import SwiftUI

struct PlatesEditorView: View {
    @Binding var plates: WeightPlates
    var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.zeroSymbol = ""
            return formatter
    }
    
    let topRowWeights = [2.5, 5.0, 10.0, 15.0]
    let bottomRowWeights =  [25.0, 35.0, 45.0, 55.0]
    
    let rectangleSizes = [2.5: CGSize(width: 35.0, height: 35.0),
                          5.0: CGSize(width: 35.0, height: 50.0),
                          10.0: CGSize(width: 35.0, height: 65.0),
                          15.0: CGSize(width: 35.0, height: 80.0),
                          25.0: CGSize(width: 35.0, height: 100.0),
                          35.0: CGSize(width: 45.0, height: 100.0),
                          45.0: CGSize(width: 55.0, height: 100.0),
                          55.0: CGSize(width: 65.0, height: 100.0)
    ]
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Base Weight")
                Spacer()
                NumberIncrementor(number: $plates.barWeight,  toString: {  "\($0.clean)"},
                                  onIncrement: {return roundedIncrement($0)},
                                  onDecrement: {return max(1.0, roundedDecrement($0))}, frame: CGSize(width: 70, height: 35), formatter: formatter)
            }
            Toggle("Mirrored", isOn: $plates.mirrored)
            HStack {
                Text("Total Weight")
                Spacer()
                Text("\(plates.weight.clean)")
            }
            VStack {
                ZStack {
                    Rectangle().frame(height: 100.0).opacity(0.0)
                    ScrollView(.horizontal) {
                        HStack(spacing: 5.0) {
                            ForEach(plates.plates) { plate in
                                ZStack {
                                    RoundedRectangle(cornerRadius: rectangleSizes[plate.weight]!.width / 4.0)
                                        .stroke(.black, lineWidth: 2.0)
                                        .frame(width:  rectangleSizes[plate.weight]!.width, height: rectangleSizes[plate.weight]!.height)
                                    Text("\(plate.weight.clean)")
                                }.onTapGesture {
                                    withAnimation {
                                        plates.plates.removeAll(where: { $0.id == plate.id })
                                    }
                                }
                                    
                            }
                            
                            Spacer()
                        }.padding(2.0)
                    }
                }
                HStack {
                    Spacer()
                    VStack {
                        ForEach([topRowWeights, bottomRowWeights], id: \.first!) { weights in
                            HStack {
                                ForEach(weights, id: \.self) { plateWeight in
                                    Button {
                                        withAnimation {
                                            plates.plates.append(WeightPlates.Plate(weight: plateWeight))
                                            plates.plates.sort { $0 > $1 }
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
            }
            
            
            
        }
    }
}


struct PlatesEditorContainer: View {
    @State var plates: WeightPlates = WeightPlates(barWeight: 45.0, plates: [])
    var id = UUID()
    @StateObject var editState: EditState = EditState()

    var body: some View {
        NavigationStack {
                PlatesEditorView(plates: $plates)
                    .environmentObject(editState)
        }
    }
}

#Preview {
    
    PlatesEditorContainer()
}
