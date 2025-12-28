import AppIntents
import Foundation

struct GlazeNoteEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Note"
    static var defaultQuery = GlazeNoteQuery()

    let id: UUID
    let title: String

    var displayRepresentation: DisplayRepresentation {
        // 문자열 보간법 사용으로 타입 오류 해결
        DisplayRepresentation(title: "\(title)")
    }
}

struct GlazeNoteQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [GlazeNoteEntity] {
        let notes = GlazeShared.loadNoteSnapshots()
        return notes
            .filter { identifiers.contains($0.id) }
            .map { GlazeNoteEntity(id: $0.id, title: $0.title) }
    }

    func suggestedEntities() async throws -> [GlazeNoteEntity] {
        let notes = GlazeShared.loadNoteSnapshots()
        guard !notes.isEmpty else {
            return [GlazeNoteEntity(id: UUID(), title: "작성된 메모가 없습니다")]
        }
        return notes.map { GlazeNoteEntity(id: $0.id, title: $0.title) }
    }
}

struct GlazeConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("메모 선택")
    static var description = IntentDescription("위젯에 표시할 메모를 선택하세요.")

    @Parameter(title: "표시할 메모")
    var note: GlazeNoteEntity?
}
