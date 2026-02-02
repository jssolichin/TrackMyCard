//
//  TrackMyCardApp.swift
//  TrackMyCard
//
//  Created by Jonathan Solichin on 2/1/26.
//

import SwiftUI
import SwiftData

@main
struct TrackMyCardApp: App {
    var sharedModelContainer: ModelContainer = SharedModelContainer.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
