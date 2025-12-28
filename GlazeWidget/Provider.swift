import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    struct Entry: TimelineEntry {
        let date: Date
        let note: GlazeNote?
    }
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, note: GlazeNote(content: "메모 내용이 여기에 표시됩니다."))
    }
    
    func snapshot(for configuration: GlazeConfigurationIntent, in context: Context) async -> Entry {
        let allNotes = GlazeShared.loadAllNotes()
        var targetNote = allNotes.first { $0.id == configuration.note?.id }
        
        // 메모가 없거나 삭제되었으면 가장 최근(첫 번째) 메모 표시
        if targetNote == nil {
            targetNote = allNotes.first
        }
        
        let noteToDisplay = targetNote ?? GlazeNote(content: "작성된 메모가 없습니다.")
        return Entry(date: .now, note: noteToDisplay)
    }
    
    func timeline(for configuration: GlazeConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        let allNotes = GlazeShared.loadAllNotes()
        var targetNote: GlazeNote? = nil
        
        if let configId = configuration.note?.id {
            targetNote = allNotes.first { $0.id == configId }
        }
        
        // Fallback Logic
        if targetNote == nil {
            targetNote = allNotes.first
        }
        
        let entry = Entry(date: .now, note: targetNote)
        return Timeline(entries: [entry], policy: .never)
    }
}
