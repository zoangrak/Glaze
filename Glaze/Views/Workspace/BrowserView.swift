import SwiftUI
import SwiftData

struct BrowserView: View {
    @Environment(\.modelContext) private var modelContext

    var folder: GlazeFolder
    @Binding var selectedId: UUID?
    @Binding var editingNote: GlazeNote?
    
    // MainScene에서 전달받는 뷰 모드
    var viewMode: ViewMode

    // 정렬 로직
    private var sortedNotes: [GlazeNote] {
        folder.notes.sorted { $0.createdAt > $1.createdAt }
    }

    // ✅ body를 아주 단순하게 만듭니다.
    var body: some View {
        Group {
            if viewMode == .list {
                listView
            } else {
                galleryView
            }
        }
    }
    
    // MARK: - Subviews (컴파일 속도 향상을 위해 분리)
    
    // 📝 1. 리스트 뷰 분리
    private var listView: some View {
        List(selection: $selectedId) {
            ForEach(sortedNotes) { note in
                HStack {
                    Label {
                        if !note.title.isEmpty {
                            Text(note.title)
                        } else if !note.content.isEmpty {
                            Text(note.content).lineLimit(1) // 내용은 한 줄만
                        } else {
                            Text("New Widget").foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    Text(note.createdAt.formatted(date: .numeric, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .tag(note.id)
                .onTapGesture(count: 2) {
                    editingNote = note
                }
                .contextMenu {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteNote(note)
                    }
                }
            }
        }
        .listStyle(.inset)
    }
    
    // 🖼️ 2. 갤러리 뷰 분리
    private var galleryView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 25) {
                
                // 새 위젯 추가 버튼
                Button(action: addNote) {
                    VStack {
                        Image(systemName: "plus.glass").font(.largeTitle)
                        Text("New Widget")
                            .fontWeight(.medium)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // 노트 목록
                ForEach(sortedNotes) { note in
                    WidgetPreviewView(note: note)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: note.cornerRadius)
                                .stroke(Color.accentColor, lineWidth: selectedId == note.id ? 3 : 0)
                        )
                        .onTapGesture(count: 2) { editingNote = note }
                        .onTapGesture(count: 1) { selectedId = note.id }
                        .contextMenu {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteNote(note)
                            }
                        }
                }
            }
            .padding(30)
        }
    }

    // MARK: - Logic
    private func addNote() {
        let newNote = GlazeNote()
        newNote.folder = folder
        modelContext.insert(newNote)
        try? modelContext.save()
        editingNote = newNote
    }
    
    private func deleteNote(_ note: GlazeNote) {
        modelContext.delete(note)
        try? modelContext.save()
    }
}
