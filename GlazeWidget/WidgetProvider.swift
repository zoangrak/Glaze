import WidgetKit
import SwiftUI
import AppIntents

struct WidgetProvider: AppIntentTimelineProvider {
    // [수정] 위에서 변경한 ConfigurationIntent 연결
    typealias Entry = WidgetEntry
    typealias Intent = ConfigurationIntent

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), note: nil)
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> WidgetEntry {
        let notes = WidgetSync.loadEntities()
        // 선택된 노트가 있으면 그걸 쓰고, 없으면 첫 번째 노트 사용 (미리보기용)
        let target = notes.first { $0.id == configuration.note?.id } ?? notes.first
        return WidgetEntry(date: Date(), note: target)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<WidgetEntry> {
        let notes = WidgetSync.loadEntities()
        // 사용자가 선택한 노트 ID와 일치하는 것을 찾음
        let target = notes.first { $0.id == configuration.note?.id } ?? notes.first
        
        let entry = WidgetEntry(date: Date(), note: target)
        return Timeline(entries: [entry], policy: .never)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let note: GlazeNoteEntity? // GlazeModels.swift가 타겟에 포함되어야 인식됨
}
