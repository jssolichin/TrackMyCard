import Foundation
import SwiftData

struct SharedModelContainer {
    static func create() -> ModelContainer {
        let schema = Schema([
            CardBenefit.self,
            UserCard.self,
        ])
        
        // IMPORTANT: Replace "group.com.example.TrackMyCard" with your actual App Group ID from Xcode Capabilities.
        // If App Group is not configured, this will fallback to the default container (separate for App and Widget).
        let appGroupIdentifier = "group.sevenBillionYou.TrackMyCard"
        
        let modelConfiguration: ModelConfiguration
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let storeURL = containerURL.appendingPathComponent("TrackMyCard.sqlite")
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            // Fallback for development without App Groups (Widget won't see App data)
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
