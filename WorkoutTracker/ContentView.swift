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
    
    @AppStorage(PALETTE) var palette: Palette = .main
    var body: some View {
        LiftListView()
    }

}

#Preview {
    ContentView()
        .modelContainer(for: [Lift.self], inMemory: true)
}
