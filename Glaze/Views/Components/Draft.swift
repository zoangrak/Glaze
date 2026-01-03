import SwiftUI
import SwiftData

struct Draft: View {
    let folder: GlazeFolder
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?
    
    // ✅ 변수 추가
    var viewMode: ViewMode

    var body: some View {
        // ✅ BrowserView로 viewMode 전달
        BrowserView(
            folder: folder,
            selectedId: $selectedNoteId,
            editingNote: $editingNote,
            viewMode: viewMode
        )
        // .navigationTitle("Drafts") // ❌ MainScene 제어 권장
    }
}
