import AppIntents
import Foundation
import WidgetKit

struct WidgetNoteEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "작품 선택"
    static var defaultQuery = WidgetNoteQuery()

    let id: UUID
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct WidgetNoteQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetNoteEntity] {
        // WidgetSync가 GlazeModels의 데이터 구조를 로드합니다.
        WidgetSync.loadEntities()
            .filter { identifiers.contains($0.id) }
            .map { WidgetNoteEntity(id: $0.id, title: $0.content.isEmpty ? "내용 없음" : String($0.content.prefix(20))) }
    }

    func suggestedEntities() async throws -> [WidgetNoteEntity] {
        let entities = WidgetSync.loadEntities()
        if entities.isEmpty {
            return []
        }
        return entities.map { WidgetNoteEntity(id: $0.id, title: $0.content.isEmpty ? "내용 없음" : String($0.content.prefix(20))) }
    }
}

// [수정] 시스템 프로토콜 이름(WidgetConfigurationIntent)과 겹치지 않게 이름 변경
struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "작품 선택"
    static var description = IntentDescription("위젯에 표시할 작품을 선택하세요.")

    @Parameter(title: "표시할 작품")
    var note: WidgetNoteEntity?
}
