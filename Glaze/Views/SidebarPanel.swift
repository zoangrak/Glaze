import SwiftUI

struct SidebarPanel: View {
    @ObservedObject var store: GlazeStore
    @Binding var selection: UUID?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(store.groups) { group in
                Section(group.name) {
                    ForEach(group.notes) { note in
                        NoteRow(note: note)
                            .tag(note.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup {
                Button { store.addGroup() } label: {
                    Image(systemName: "folder.badge.plus")
                }
                Button { addNoteToCurrentGroup() } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    
    private func addNoteToCurrentGroup() {
        var targetGroupId: UUID?
        
        if let selection = selection {
            targetGroupId = store.groups.first(where: { group in
                group.notes.contains(where: { $0.id == selection })
            })?.id
        }
        
        if targetGroupId == nil {
            targetGroupId = store.groups.first?.id
        }
        
        if let groupId = targetGroupId {
            let newNote = store.addNote(to: groupId)
            self.selection = newNote.id
        }
    }
}

// 컴파일러 성능 최적화를 위한 별도 뷰
struct NoteRow: View {
    let note: GlazeNote
    var body: some View {
        Text(note.title)
            .lineLimit(1)
            .foregroundStyle(note.content.isEmpty ? .secondary : .primary)
    }
}
