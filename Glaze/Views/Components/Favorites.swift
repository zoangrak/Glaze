import SwiftUI
import SwiftData

struct Favorites: View {
    // ✨ isPinned가 true인 노트만 필터링
    @Query(filter: #Predicate<GlazeNote> { $0.isPinned }, sort: \GlazeNote.createdAt, order: .reverse)
    private var pinnedNotes: [GlazeNote]
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?
    
    // ✅ MainScene에서 받아올 변수 추가
    var viewMode: ViewMode

    var body: some View {
        Group {
            if viewMode == .list {
                // 📝 리스트 모드
                List(selection: $selectedNoteId) {
                    ForEach(pinnedNotes) { note in
                        HStack {
                            Label {
                                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                            } icon: {
                                Image(systemName: "star.fill") // 즐겨찾기니까 별 아이콘
                                    .foregroundStyle(.yellow)
                            }
                            Spacer()
                            Text(note.createdAt.formatted(date: .numeric, time: .shortened))
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                        .tag(note.id)
                        .onTapGesture(count: 2) {
                            editingNote = note
                        }
                        .contextMenu {
                            Button("Edit") { editingNote = note }
                            // 핀 해제 기능 등 추가 가능
                        }
                    }
                }
                .listStyle(.inset)
            } else {
                // 🖼️ 갤러리 모드 (기존 코드)
                ScrollView {
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
        }
        // .navigationTitle("Favorites") // ❌ MainScene에서 타이틀을 제어하므로 삭제
    }
}
