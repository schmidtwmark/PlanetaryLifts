//
//  LiftListView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

struct LiftListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var lifts: [Lift]
    
    
    var body: some View {
        NavigationStack {
            List(lifts) { lift in
                HStack {
                    Text(lift.type)
                    Spacer()
                    Text(lift.timestamp.description)
                }
            }
            .navigationTitle("Lifts")
            .toolbar() {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink(value: Lift(type: "Bench Press", sets: [], timestamp: Date.now), label: {
                        Label("Add Lift", systemImage: "plus")
                    })
                })
            }
            .navigationDestination(for: Lift.self) { lift in
                AddLiftView(lift: lift).onAppear {
                    modelContext.insert(lift)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lift.self, LiftSet.self, configurations: config)
    
    let lift = Lift(type: "Bench Press", sets: [], timestamp: Date.now)
    container.mainContext.insert(lift)

    return LiftListView()
        .modelContainer(container)
}
