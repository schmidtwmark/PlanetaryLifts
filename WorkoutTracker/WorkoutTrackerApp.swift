//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 2/29/24.
//

import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        if let cloudContainer = try? ModelContainer(
            for: Lift.self,
            UserGeneratedLiftType.self,
            LiftGroup.self,
            configurations: .init(
                "iCloud.planetary-lifts.container"
            )
        ) {
            return cloudContainer
        }
        // If failed to get cloud container, just make a local container
        return try! ModelContainer(for: Lift.self,
                                   UserGeneratedLiftType.self,
                                   LiftGroup.self)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
