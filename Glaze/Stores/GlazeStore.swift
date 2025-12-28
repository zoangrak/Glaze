import SwiftUI
import WidgetKit
internal import Combine

@MainActor
final class GlazeStore: ObservableObject {

    @Published var sections: [GlazeSection] = []

    init() {
        sections = [
            GlazeSection(
                name: "Notes",
                notes: [
                    GlazeGroup(name: "First Note", content: "Hello Glaze")
                ]
            )
        ]
    }

    var allGroups: [GlazeGroup] {
        sections.flatMap { $0.notes }
    }

    func addSection() {
        sections.append(GlazeSection(name: "New Notes"))
    }

    func addNote(to sectionId: UUID) -> GlazeGroup {
        let note = GlazeGroup(name: "New Note")
        guard let i = sections.firstIndex(where: { $0.id == sectionId }) else {
            return note
        }
        sections[i].notes.insert(note, at: 0)
        return note
    }

    func update(note: GlazeGroup) {
        for s in sections.indices {
            if let n = sections[s].notes.firstIndex(where: { $0.id == note.id }) {
                sections[s].notes[n] = note
            }
        }
    }
    
    func toggleCompletion(id: UUID) {
        for sectionIndex in sections.indices {
            if let noteIndex = sections[sectionIndex]
                .notes
                .firstIndex(where: { $0.id == id }) {

                sections[sectionIndex]
                    .notes[noteIndex]
                    .isCompleted
                    .toggle()

                return
            }
        }
    }
}

