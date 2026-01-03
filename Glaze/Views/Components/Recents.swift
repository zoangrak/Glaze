import SwiftUI
import SwiftData

struct Recents: View {
    // [핵심] 폴더 구분 없이, DB에 있는 모든 노트를 생성일(또는 수정일) 역순으로 로드
    @Query(sort: \GlazeNote.createdAt, order: .reverse) private var allNotes: [GlazeNote]
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?

    var body: some View {
        ScrollView {
            // 노트가 하나도 없을 때 안내 문구
            if allNotes.isEmpty {
                ContentUnavailableView(
                    "작성된 노트가 없습니다",
                    systemImage: "note.text",
                    description: Text("+ 버튼을 눌러 첫 번째 기록을 남겨보세요.")
                )
                .padding(.top, 50)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 25) {
                    ForEach(allNotes) { note in
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
        .navigationTitle("Recents") // 상단 타이틀
    }
}
