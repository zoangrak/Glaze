import SwiftUI
import SwiftData

struct Favorites: View {
    // ✨ isPinned가 true인 노트만 필터링
    @Query(filter: #Predicate<GlazeNote> { $0.isPinned }, sort: \GlazeNote.createdAt, order: .reverse)
    private var pinnedNotes: [GlazeNote]
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?

    var body: some View {
        ScrollView {
            if pinnedNotes.isEmpty {
                ContentUnavailableView(
                    "즐겨찾기 된 노트가 없습니다",
                    systemImage: "star.slash",
                    description: Text("중요한 노트의 속성창에서 별표를 체크해보세요.")
                )
                .padding(.top, 50)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 25) {
                    ForEach(pinnedNotes) { note in
                        WidgetPreviewView(note: note)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: note.cornerRadius)
                                    .stroke(Color.accentColor, lineWidth: selectedNoteId == note.id ? 3 : 0)
                            )
                            .onTapGesture(count: 2) {
                                editingNote = note
                            }
                            .onTapGesture(count: 1) {
                                selectedNoteId = note.id
                            }
                    }
                }
                .padding(30)
            }
        }
        .navigationTitle("Favorites")
    }
}
