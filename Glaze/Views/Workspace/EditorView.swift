import SwiftUI

struct EditorView: View {
    @Bindable var note: GlazeNote
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "chevron.left").font(.title3.bold())
                }.buttonStyle(.plain).padding()
                Spacer()
            }
            TextEditor(text: $note.content)
                .font(.system(size: 22))
                .scrollContentBackground(.hidden)
                .padding(60)
                .background(Color(hex: note.backgroundColorHex).opacity(0.1))
                // [추가] 텍스트 변경 감지하여 위젯 업데이트
                .onChange(of: note.content) { _, _ in
                    note.lastModified = Date()
                    // 실시간 타이핑마다 저장이 부담스럽다면, Combine의 debounce를 쓰거나
                    // 여기서 최소한의 갱신을 수행.
                    // 간단한 앱이라면 바로 호출해도 무방함.
                    WidgetSync.reload(notes: [note])
                }
        }
    }
}
