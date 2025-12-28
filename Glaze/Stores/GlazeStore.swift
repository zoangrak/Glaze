import SwiftUI
import Combine

@MainActor
final class GlazeStore: ObservableObject {

    @Published var groups: [GlazeGroup] = []

    init() {
        let loaded = GlazeShared.loadGroups()

        if loaded.isEmpty {
            self.groups = [
                GlazeGroup(
                    name: "Notes",
                    notes: [GlazeNote(content: "Hallo, Glaze")]
                )
            ]
            save()
        } else {
            self.groups = loaded
        }
    }

    // 편의용: 모든 노트 접근
    var allNotes: [GlazeNote] {
        groups.flatMap { $0.notes }
    }

    func save() {
        GlazeShared.save(groups: groups)
    }

    func addGroup() {
        groups.append(GlazeGroup(name: "New Notes"))
        save()
    }

    func addNote(to groupId: UUID) -> GlazeNote {
        let note = GlazeNote()

        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].notes.insert(note, at: 0)
            save()
        }

        return note
    }

    func update(note: GlazeNote) {
        var changed = false

        for g in groups.indices {
            if let n = groups[g].notes.firstIndex(where: { $0.id == note.id }) {
                if groups[g].notes[n] != note {
                    groups[g].notes[n] = note
                    changed = true
                }
            }
        }

        if changed { save() }
    }
}
