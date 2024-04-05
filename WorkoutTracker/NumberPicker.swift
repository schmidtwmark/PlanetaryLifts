//
//  NumberPicker.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/4/24.
//

import SwiftUI

struct StepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 50, height: 50)
            .foregroundColor(Color(uiColor: UIColor.label))
            .background(Color(uiColor: UIColor.secondarySystemFill))
            .cornerRadius(10.0)
    }
}

struct NumberPicker<T: Numeric> : View {
    @Binding var number: T
    @AppStorage("weightUnits") var weightUnits: WeightUnits = .pounds
    
    var toString: ((T) -> String)
    
    var onIncrement: ((T) -> T)
    var onDecrement: ((T) -> T)
    
    enum NumberType {
        case weight
        case reps
        
        func getSingleUnitString(_ weightUnits: WeightUnits) -> String {
            return switch self {
            case .weight: weightUnits.singleUnit
            case .reps: "rep"
            }
        }
    }
    
    var type: NumberType
    var id: UUID
    
    var selected : Bool {
        switch type {
        case .weight: editState.setEditMode == .weight(id)
        case .reps: editState.setEditMode == .reps(id)
        }
    }
    
    var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            if type == .weight {
                formatter.numberStyle = .decimal
            }
            formatter.zeroSymbol = ""
            return formatter
    }
    
    var keyboardType: UIKeyboardType {
        return switch type {
            case .weight: .decimalPad
            case .reps: .numberPad
        }
    }
    
    @EnvironmentObject var editState: EditState
    @FocusState var isInputActive: Bool

    
    var body: some View {
        HStack {
            Group {
                if selected {
                    HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                        Button {
                            number = onDecrement(number)
                        } label: {
                            Image(systemName: "minus")
                        }.buttonStyle(StepperButtonStyle())
//                        Text("\(number)")
                        TextField("", value: $number, formatter: formatter)
                            .keyboardType(.decimalPad)
                            .focused($isInputActive)
                            .multilineTextAlignment(.center)
                            .frame(width: 100, height: 50 )
                            .fontWeight(.bold)
                            .background(Color(uiColor: UIColor.secondarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        Button {
                            number = onIncrement(number)
                        } label: {
                            Image(systemName: "plus")
                        }.buttonStyle(StepperButtonStyle())
                        Spacer()
                        Text("\(type.getSingleUnitString(weightUnits))\(number != 1 ? "s" : "")")
                            .onTapGesture {
                                withAnimation {
                                    isInputActive = false
                                    editState.setEditMode = .none
                                }
                        }
                        Spacer()
                    }
                    .toolbar { ToolbarItemGroup(placement: .keyboard, content: {
                        Spacer()
                        Button {
                            withAnimation {
                                isInputActive = false
                                editState.setEditMode = .none
                            }
                        } label: {
                            Label("Done", systemImage: "checkmark").labelStyle(.titleOnly)
                        }
                        })
                    }

                } else {
                    Spacer()
                    Group {
                        Text("\(toString(number))")
                            .fontWeight(.bold)
                        Text("\(type.getSingleUnitString(weightUnits))\(number != 1 ? "s" : "")")
                    }
                    .onTapGesture {
                        withAnimation {
                            editState.setEditMode = switch type {
                            case .weight: .weight(id)
                            case .reps: .reps(id)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return 0
        }
    }
}

struct NumberPickerContainer : View{
    @State var number = 5
    var id = UUID()
    @StateObject var editState: EditState = EditState()

    var body: some View {
        NavigationStack {
            NumberPicker(number: $number, toString: {"\($0)"}, onIncrement: { return $0 + 1}, onDecrement: { return $0 - 1}, type: .reps, id: id)
            .environmentObject(editState)
        }
    }
}

#Preview {
    NumberPickerContainer()
}
