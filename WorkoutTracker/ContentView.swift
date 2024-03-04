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
            LiftListView().tabItem {
                Label("Lifts", systemImage: "dumbbell")
            }
            StatsView().tabItem {
                Label("Stats", systemImage: "chart.xyaxis.line")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: [Lift.self], inMemory: true)
}
