import SwiftUI

struct InspectorView: View {
    @Bindable var note: GlazeNote
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            WidgetPreviewView(note: note)
                .frame(width: 200, height: 200)
                .padding(.top, 40).shadow(radius: 10)
            
            Form {
                // ✨ [추가] 정보 섹션
                Section("정보") {
                    Toggle(isOn: $note.isPinned) {
                        Label("즐겨찾기", systemImage: "star.fill")
                            .foregroundStyle(note.isPinned ? .yellow : .primary)
                    }
                    
                    // 빵부스러기: 이 노트가 어디 소속인지 알려줌
                    if let folder = note.folder {
                        HStack {
                            Text("위치")
                            Spacer()
                            Text("\(folder.collection?.name ?? "") > \(folder.name)")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Section("스타일") {
                    // ... (기존 스타일 설정)
                }
            }.formStyle(.grouped)
        }
        .background(.ultraThinMaterial)
    }

    private func sync() {
        note.lastModified = Date()
        // 위젯에 현재 상태 동기화
        WidgetSync.reload(notes: [note])
    }
}
