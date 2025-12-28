import SwiftUI
import WidgetKit
internal import Combine

@MainActor
final class GlazeStore: ObservableObject {

    @Published var sections: [GlazeSection] = []

    init() {
        // 1. 저장된 데이터가 있는지 먼저 확인 (Persistence)
        if let savedSections = GlazeShared.loadSections() {
            self.sections = savedSections
        } else {
            // 2. 없으면 기본값(초기 상태) 사용
            self.sections = [
                GlazeSection(
                    name: "Notes",
                    notes: [
                        GlazeGroup(name: "First Note", content: "Hallo, Glaze")
                    ]
                )
            ]
            // 초기 데이터도 파일로 한번 저장해두는 게 좋음
            save()
        }
    }

    var allGroups: [GlazeGroup] {
        sections.flatMap { $0.notes }
    }
    
    func save() {
        GlazeShared.save(sections: self.sections)
        print("💾 Cmd+S Forced Save Triggered")
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
        // 내용이 실제로 바뀌었을 때만 로직 수행 (최적화)
        var changed = false
        
        for s in sections.indices {
            if let n = sections[s].notes.firstIndex(where: { $0.id == note.id }) {
                // 기존 내용과 다를 때만 업데이트
                if sections[s].notes[n] != note {
                    sections[s].notes[n] = note
                    changed = true
                }
            }
        }
        
        if changed {
            save()
        }
    }
}

