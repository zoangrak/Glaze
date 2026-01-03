import SwiftUI
import SwiftData

@main
struct GlazeApp: App {
    var body: some Scene {
        WindowGroup {
            MainScene()
        }

        .modelContainer(for: [GlazeCollection.self, GlazeFolder.self, GlazeNote.self])
        .windowStyle(.hiddenTitleBar)
    }
}
