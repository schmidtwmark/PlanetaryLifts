//
//  BindingPlayground.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 4/4/24.
//

import SwiftUI


struct TestData : Hashable, Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var number: Int
    var weight: Double = 0.0
}

struct InnerView: View {
    @Binding var data: TestData
    
    var body: some View {
        HStack {
            Text("Inner: \(data.number)")
            Button {
                data.number += 1
            } label: {
                Text("increment")
            }
        }
    }
}

struct BindingPlayground: View {
    
    @State var numbers : [TestData] = []
    
    var body: some View {
        VStack {
            ForEach($numbers) { $number in
                Text("Outer: \(number.number)")
                InnerView(data: $number)
            }
            Button {
                numbers.append(TestData(number: Int.random(in: 0...10)))
            } label: {
                Text("New Number")
            }
        }
    }
}

struct InnerView2: View {
    @Binding var data: Int
    
    var body: some View {
        HStack {
            Text("Inner: \(data)")
            Button {
                data += 1
            } label: {
                Text("increment")
            }
        }
    }
}

struct BindingPlayground2: View {
    
    @State var liftSets: [LiftSet] = []
    
    var body: some View {
        VStack {
            ForEach($liftSets) { $liftSet in
                Text("Outer: \(liftSet.reps)")
                InnerView2(data: $liftSet.reps)
            }
            Button {
                liftSets.append(LiftSet(reps: Int.random(in: 1...10), weight: 20, units: .pounds))
            } label: {
                Text("New Set")
            }
        }
    }
}

struct EnumPlayground: View {
    enum StateEnum {
        case a(Int)
        
    }
    
    @State var state: StateEnum = .a(5)
    
    var body: some View {
        if case .a = state {
            Incrementor(a: Binding(get: { if case .a(let a) = state { return a } else { return 0 }}, set: { state = .a($0)}))
        }

    }
}

struct Incrementor : View {
    @Binding var a: Int
    var body: some View {
        VStack{
            Text("A: \(a)")
            Button {
                a += 1
            } label: {
                Text("Add")
            }
        }
    }
}

#Preview("TestData") {
    BindingPlayground()
}
#Preview("LiftSet") {
    BindingPlayground2()
}

#Preview("SwitchBindings") {
    EnumPlayground()
}
