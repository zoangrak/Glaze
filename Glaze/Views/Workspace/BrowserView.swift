import SwiftUI
import SwiftData // 1. SwiftData 임포트 필수

struct BrowserView: View {
    // 2. 모델 컨텍스트 변수 선언 필수
    @Environment(\.modelContext) private var modelContext

    var folder: GlazeFolder
    @Binding var selectedId: UUID?
    @Binding var editingNote: GlazeNote?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 25) {
                Button(action: addNote) {
                    VStack {
                        Image(systemName: "plus.glass").font(.largeTitle)
                        Text("새 위젯")
                    }
                    .frame(height: 200).frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                }.buttonStyle(.plain)

                ForEach(folder.notes) { note in
                    WidgetPreviewView(note: note)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: note.cornerRadius)
                                .stroke(Color.accentColor, lineWidth: selectedId == note.id ? 3 : 0)
                        )
                        .onTapGesture(count: 2) { editingNote = note }
                        .onTapGesture(count: 1) { selectedId = note.id }
                }
            }.padding(30)
        }
    }

    private func addNote() {
        let newNote = GlazeNote()
        newNote.folder = folder // 관계 설정
        
        // 이제 modelContext가 선언되었으므로 오류가 나지 않습니다.
        modelContext.insert(newNote)
        
        // 생성 직후 에디터 열기
        editingNote = newNote
    }
}
