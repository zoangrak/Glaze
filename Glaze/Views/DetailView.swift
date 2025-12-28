import SwiftUI

struct DetailView: View {
    @ObservedObject var store: GlazeStore
    @Binding var selection: UUID?
    
    var body: some View {
        if let note = selectedNote {
            EditorView(note: note) { updatedNote in
                store.update(note: updatedNote)
            }
        } else {
            Text("No Selection")
                .foregroundStyle(.secondary)
        }
    }
    
    private var selectedNote: GlazeNote? {
        guard let id = selection else { return nil }
        return store.allNotes.first { $0.id == id }
    }
}
