import SwiftUI
import SwiftData

struct Draft: View {
    let folder: GlazeFolder
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?

    var body: some View {
        BrowserView(
            folder: folder,
            selectedId: $selectedNoteId,
            editingNote: $editingNote
        )
        .navigationTitle("Drafts") // 타이틀 강제 고정
        // .navigationBarBackButtonHidden(true) // 필요하면 이런 옵션 추가 가능
    }
}
