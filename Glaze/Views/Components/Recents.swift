import SwiftUI
import SwiftData

struct Recents: View {
    // 최신순 정렬
    @Query(sort: \GlazeNote.createdAt, order: .reverse) private var allNotes: [GlazeNote]
    
    @Binding var selectedNoteId: UUID?
    @Binding var editingNote: GlazeNote?
    
    // ✅ MainScene에서 전달받은 뷰 모드
    var viewMode: ViewMode

    var body: some View {
        Group {
            if viewMode == .list {
                // 📝 1. 리스트 모드 (List View)
                List(selection: $selectedNoteId) {
                    ForEach(allNotes) { note in
                        HStack {
                            // 아이콘 + 제목
                            Label {
                                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            } icon: {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(.blue)
                            }
                            
                            Spacer()
                            
                            // 날짜/시간 표시 (보조 정보)
                            Text(note.createdAt.formatted(date: .numeric, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .tag(note.id) // ✅ 선택(Selection)을 위해 필수
                        // 더블 클릭 시 편집 모드 진입
                        .onTapGesture(count: 2) {
                            editingNote = note
                        }
                        // 우클릭 메뉴 (선택 사항)
                        .contextMenu {
                            Button("Edit") { editingNote = note }
                            Divider()
                            Button("Delete", role: .destructive) {
                                // 삭제 로직 (필요시 modelContext 추가하여 구현)
                            }
                        }
                    }
                }
                .listStyle(.inset) // 깔끔한 인셋 스타일
                
            } else {
                // 🖼️ 2. 갤러리 모드 (기존 코드 유지)
                ScrollView {
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
        }
        // ⚠️ 중요: MainScene에서 이미 타이틀을 설정하고 있으므로,
        // 여기서 .navigationTitle("Recents")를 또 쓰면 충돌하거나 레이아웃이 이상해질 수 있습니다.
        // 따라서 여기서는 제거하는 것이 좋습니다.
    }
}
