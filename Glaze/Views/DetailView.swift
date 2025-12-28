import SwiftUI

struct DetailView: View {
    @ObservedObject var store: GlazeStore
    @Binding var selection: UUID?

    var body: some View {
        if let group = selectedGroup {
            EditorView(group: group) { updated in
                store.update(note: updated)
            }
        } else {
            Text("No Selection")
                .foregroundStyle(.secondary)
        }
    }

    private var selectedGroup: GlazeGroup? {
        guard let id = selection else { return nil }
        return store.allGroups.first { $0.id == id }
    }
}

