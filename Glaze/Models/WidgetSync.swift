import Foundation
import WidgetKit
import SwiftData

struct WidgetSync {
    static let appGroup = "group.Keusae.Glaze"
    static let suite = UserDefaults(suiteName: appGroup)
    static let key = "saved_glaze_notes"

    // 앱에서 호출: SwiftData의 노트를 위젯용으로 저장
    static func reload(notes: [GlazeNote]) {
        let entities = notes.map { note in
            GlazeNoteEntity(
                id: note.id,
                content: note.content,
                backgroundColorHex: note.backgroundColorHex,
                textColorHex: note.textColorHex,
                cornerRadius: note.cornerRadius,
                hAlignment: note.hAlignment,
                fontSize: note.fontSize,
                fontWeight: note.fontWeight
            )
        }
        
        if let encoded = try? JSONEncoder().encode(entities) {
            suite?.set(encoded, forKey: key)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    // 위젯에서 호출: 저장된 엔티티 로드
    static func loadEntities() -> [GlazeNoteEntity] {
        guard let data = suite?.data(forKey: key),
              let notes = try? JSONDecoder().decode([GlazeNoteEntity].self, from: data) else {
            return []
        }
        return notes
    }
}
