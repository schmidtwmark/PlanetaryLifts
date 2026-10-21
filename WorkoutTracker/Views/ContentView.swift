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
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage(PALETTE) var palette: Palette = .main
    @State private var suggestionStore = SuggestionStore()
    @AppStorage(SUGGESTION_MODEL) private var suggestionModel: SuggestionModel = .onDevice

    var body: some View {
        LiftListView(modelContext: modelContext)
            .environment(suggestionStore)
            .task {
                suggestionStore.refresh(modelContext: modelContext)
            }
            // Debounced so a burst of saves while logging sets triggers one run
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
                suggestionStore.refresh(modelContext: modelContext, after: .seconds(3))
            }
            .onChange(of: suggestionModel) {
                suggestionStore.refresh(modelContext: modelContext, clearingResults: true)
            }
            // Picks up a model that finished downloading or a transient failure
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                switch suggestionStore.status {
                case .unavailable, .failed:
                    suggestionStore.refresh(modelContext: modelContext)
                case .unsupported, .loading, .ready:
                    break
                }
            }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: [Lift.self, UserGeneratedLiftType.self], inMemory: true)
}
