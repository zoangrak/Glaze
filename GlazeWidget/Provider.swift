import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    // 뷰에 전달할 데이터 꾸러미
    struct Entry: TimelineEntry {
        let date: Date
        let group: GlazeGroup?
    }

    // 1. 위젯 갤러리용 껍데기
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, group: GlazeGroup(name: "Example", content: "메모 미리보기"))
    }

    // 2. 미리보기 스냅샷
    func snapshot(for configuration: GlazeConfigurationIntent, in context: Context) async -> Entry {
        let allGroups = GlazeShared.loadAllGroups()
        // 설정된 게 있으면 그거, 없으면 첫 번째 것
        let group = allGroups.first { $0.id == configuration.group?.id } ?? allGroups.first
        return Entry(date: .now, group: group)
    }

    // 3. 실제 타임라인 생성 (가장 중요)
    func timeline(for configuration: GlazeConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        
        // A. 매니저를 통해 최신 데이터 로드
        let allGroups = GlazeShared.loadAllGroups()
        
        // B. 사용자가 선택한 노트 찾기
        var selectedGroup: GlazeGroup?
        
        if let configId = configuration.group?.id {
            selectedGroup = allGroups.first { $0.id == configId }
        }
        
        // C. 만약 선택된 게 없으면(삭제됨 or 미선택) 가장 최근 것 보여주기 (옵션)
        if selectedGroup == nil {
            selectedGroup = allGroups.first
        }

        // D. 타임라인 반환 (.never: 앱에서 저장할 때만 갱신)
        let entry = Entry(date: .now, group: selectedGroup)
        return Timeline(entries: [entry], policy: .never)
    }
}
