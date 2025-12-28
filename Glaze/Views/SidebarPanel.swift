import SwiftUI

struct SidebarPanel: View {
    @ObservedObject var store: GlazeStore
    @Binding var selection: UUID?

    var body: some View {
        List(selection: $selection) {
            ForEach(store.sections) { section in
                Section(section.name) {
                    ForEach(section.notes) { note in
                        Text(note.name)
                            .tag(note.id)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.addSection()
                } label: {
                    Image(systemName: "folder.badge.plus")
                }

                Button {
                    if let section = store.sections.first {
                        let note = store.addNote(to: section.id)
                        selection = note.id
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}

