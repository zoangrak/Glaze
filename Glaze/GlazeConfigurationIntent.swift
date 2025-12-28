import AppIntents
import WidgetKit
import Foundation

public enum VerticalPosition: String, AppEnum {
    case top, center, bottom
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "세로 정렬"
    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .top: "상단", .center: "중간", .bottom: "하단"
    ]
}

public enum HorizontalAlignmentOption: String, AppEnum {
    case leading, center, trailing
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "가로 정렬"
    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .leading: "좌측", .center: "가운데", .trailing: "우측"
    ]
}

// 그룹 선택 엔티티
struct GlazeGroupEntity: AppEntity {
    var id: UUID
    var title: String
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Bingo Board"
    static var defaultQuery = GlazeGroupQuery()
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(title)") }
}

struct GlazeGroupQuery: EntityQuery {
    // 1. 특정 ID들에 해당하는 엔티티 반환
    func entities(for identifiers: [UUID]) async throws -> [GlazeGroupEntity] {
        // MainActor에서 안전하게 데이터를 가져오도록 수정
        return await MainActor.run {
            let store = GlazeStore() // 메인 액터 내부에서 생성
            let groups = store.allGroups
            return groups
                .filter { identifiers.contains($0.id) }
                .map { GlazeGroupEntity(id: $0.id, title: $0.name) }
        }
    }
    
    // 2. 위젯 설정 창에 뜰 추천 리스트 반환
    func suggestedEntities() async throws -> [GlazeGroupEntity] {
        return await MainActor.run {
            let store = GlazeStore()
            let groups = store.allGroups
            return groups.map { GlazeGroupEntity(id: $0.id, title: $0.name) }
        }
    }
}

struct GlazeConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Glaze 설정"
    static var description = IntentDescription("위젯에 표시할 그룹과 정렬을 선택하세요.")

    @Parameter(title: "Group 선택")
    var group: GlazeGroupEntity?

    @Parameter(title: "세로 정렬", default: .center)
    var vertical: VerticalPosition

    @Parameter(title: "가로 정렬", default: .center)
    var horizontal: HorizontalAlignmentOption
    
    init() {}
}
