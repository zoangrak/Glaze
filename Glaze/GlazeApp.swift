import SwiftUI

@main
struct GlazeApp: App {
    @StateObject private var store = GlazeStore()
    @State private var selection: UUID?

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarPanel(store: store, selection: $selection)
                    .navigationSplitViewColumnWidth(min: 235, ideal: 235, max: 255)
            } detail: {
                DetailView(store: store, selection: $selection)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    store.save()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            SidebarCommands()
        }
    }
}
