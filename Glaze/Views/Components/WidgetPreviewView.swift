import SwiftUI

struct WidgetPreviewView: View {
    let note: GlazeNote

    var body: some View {
        ZStack(alignment: alignment) {
            // ... (배경 및 텍스트 기존 코드)
            
            // ✨ [추가] 우측 하단에 소속 폴더 표시 (Smart View에서 유용)
            // 너무 작으면 안 보일 수 있으니 조건부로 표시하거나 디자인 조정 필요
            if let folderName = note.folder?.name {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(folderName)
                            .font(.caption2)
                            .padding(6)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: note.cornerRadius))
    }

    private var alignment: Alignment { [.leading, .center, .trailing][note.hAlignment] }
    private var textAlignment: TextAlignment { [.leading, .center, .trailing][note.hAlignment] }
}

