import SwiftUI
import SwiftData

@main
struct GlazeApp: App {
    var body: some Scene {
        WindowGroup {
            MainScene()
                .toolbarBackground(.hidden, for: .windowToolbar)
        }

        .modelContainer(for: [GlazeCollection.self, GlazeFolder.self, GlazeNote.self])
        .windowToolbarStyle(.unified)
    }
}
