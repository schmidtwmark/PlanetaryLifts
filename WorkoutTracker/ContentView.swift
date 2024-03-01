//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        TabView {
            WorkoutListView().tabItem {
                Label("Workouts", systemImage: "figure.strengthtraining.traditional")
            }
            LiftListView().tabItem {
                Label("Lifts", systemImage: "dumbbell")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, Lift.self, LiftSet.self], inMemory: true)
}
