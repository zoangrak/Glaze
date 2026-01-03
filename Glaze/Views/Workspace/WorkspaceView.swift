import SwiftUI

struct WorkspaceView: View {
    var folder: GlazeFolder
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?
    
    var viewMode: ViewMode

    var body: some View {
        ZStack {
            if let note = editingNote {
                EditorView(note: note) {
                    withAnimation(.spring(response: 0.4)) { editingNote = nil }
                }
            } else {
                BrowserView(
                    folder: folder,
                    selectedId: $selectedNoteId,
                    editingNote: $editingNote,
                    viewMode: viewMode
                )
            }
        }
    }
}
