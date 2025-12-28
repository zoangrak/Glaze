import Foundation
import WidgetKit

struct GlazeShared {
    // 전역 상수도 격리 해제
    nonisolated static let appGroup = "group.Keusae.Glaze"
    nonisolated static let dataKey = "saved_glaze_data"

    // MARK: - Save (앱에서 호출)
    nonisolated static func save(groups: [GlazeGroup]) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let defaults = UserDefaults(suiteName: appGroup) else { return }

            if let encoded = try? JSONEncoder().encode(groups) {
                defaults.set(encoded, forKey: dataKey)
                // 저장 즉시 위젯 타임라인 갱신 요청
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    // MARK: - Load (앱 & 위젯 공용)
    nonisolated static func loadGroups() -> [GlazeGroup] {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: dataKey),
              let groups = try? JSONDecoder().decode([GlazeGroup].self, from: data)
        else {
            return []
        }
        return groups
    }
    
    // 위젯 Provider에서 사용 (모든 메모 평탄화)
    nonisolated static func loadAllNotes() -> [GlazeNote] {
        return loadGroups().flatMap { $0.notes }
    }
    
    // Intent에서 사용 (가벼운 스냅샷)
    nonisolated static func loadNoteSnapshots() -> [GlazeNoteSnapshot] {
        return loadAllNotes().map { note in
            // 안전하게 여기서 제목을 직접 계산 (MainActor 충돌 방지)
            let trimmed = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let safeTitle: String
            
            if trimmed.isEmpty {
                safeTitle = "New Note"
            } else {
                let firstLine = trimmed.components(separatedBy: .newlines).first ?? ""
                safeTitle = String(firstLine.prefix(50))
            }
            
            return GlazeNoteSnapshot(id: note.id, title: safeTitle)
        }
    }
}

// Intent용 경량 모델
public struct GlazeNoteSnapshot: Identifiable, Sendable, Codable {
    public let id: UUID
    public let title: String
    
    nonisolated public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}
