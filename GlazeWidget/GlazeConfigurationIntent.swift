import AppIntents
import WidgetKit
import Foundation

struct GlazeGroupEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Note"
    static var defaultQuery = GlazeGroupQuery()

    var id: UUID
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

// 2. 데이터를 찾아오는 검색원 (Manager 사용)
struct GlazeGroupQuery: EntityQuery {
    
    // 특정 ID로 노트 찾기
    func entities(for identifiers: [UUID]) async throws -> [GlazeGroupEntity] {
        // ✨ 아까 만든 Shared를 통해 실제 데이터 불러오기
        let allGroups = GlazeShared.loadAllGroups()
        
        return allGroups
            .filter { identifiers.contains($0.id) }
            .map { GlazeGroupEntity(id: $0.id, title: $0.name) }
    }
    
    // 설정 목록에 뜰 추천 리스트
    func suggestedEntities() async throws -> [GlazeGroupEntity] {
        let allGroups = GlazeShared.loadAllGroups()
        
        // 데이터가 없으면 안내용 가짜 데이터 하나 띄워줄 수도 있음 (선택 사항)
        if allGroups.isEmpty {
            return [GlazeGroupEntity(id: UUID(), title: "작성된 메모가 없습니다")]
        }
        
        return allGroups.map { group in
            GlazeGroupEntity(id: group.id, title: group.name)
        }
    }
}

// 3. 실제 위젯 설정 정의
struct GlazeConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "메모 선택"
    static var description = IntentDescription("위젯에 표시할 메모를 선택하세요.")

    @Parameter(title: "표시할 메모")
    var group: GlazeGroupEntity?
}
