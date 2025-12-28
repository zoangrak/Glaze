import Foundation
import WidgetKit

struct GlazeShared {
    static let appGroup = "group.Keusae.Glaze"
    static let dataKey = "saved_glaze_data"

    // MARK: - Save (앱에서 사용)
    /// 앱의 데이터를 통째로 저장하고 위젯을 깨웁니다.
    static func save(sections: [GlazeSection]) {
        // 백그라운드 스레드에서 저장 (UI 버벅임 방지)
        DispatchQueue.global(qos: .background).async {
            guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
                print("❌ App Group 연결 실패: ID를 확인하세요.")
                return
            }
            
            if let encoded = try? JSONEncoder().encode(sections) {
                sharedDefaults.set(encoded, forKey: dataKey)
                print("💾 위젯 데이터 저장 완료")
                
                // 위젯에게 "데이터 바뀌었으니 다시 그려!" 라고 소리치기
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    // MARK: - Load (위젯 & Intent에서 사용)
    /// 저장된 모든 노트를 불러옵니다.
    static func loadAllGroups() -> [GlazeGroup] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
            return []
        }
        
        guard let data = sharedDefaults.data(forKey: dataKey),
              let sections = try? JSONDecoder().decode([GlazeSection].self, from: data) else {
            return []
        }
        
        // 섹션 안에 있는 노트들을 다 꺼내서 하나의 배열로 만듦
        return sections.flatMap { $0.notes }
    }
    
    static func loadSections() -> [GlazeSection]? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup),
              let data = sharedDefaults.data(forKey: dataKey),
              let sections = try? JSONDecoder().decode([GlazeSection].self, from: data) else {
            return nil
        }
        return sections
    }
}
