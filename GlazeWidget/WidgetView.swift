import SwiftUI
import WidgetKit

struct WidgetView: View {
    var entry: WidgetProvider.Entry

    var body: some View {
        ZStack(alignment: alignment) {
            if let note = entry.note {
                // 배경색 반영
                Color(hex: note.backgroundColorHex)
                
                // 텍스트 반영 (본체 앱의 WidgetPreviewView 로직과 동일)
                Text(note.content.isEmpty ? "영감을 채우세요" : note.content)
                    .font(.system(size: note.fontSize, weight: note.fontWeight == "Bold" ? .bold : .regular))
                    .foregroundStyle(Color(hex: note.textColorHex))
                    .multilineTextAlignment(textAlignment)
                    .padding(20)
            } else {
                Text("작품을 선택해주세요").foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            if let note = entry.note {
                Color(hex: note.backgroundColorHex)
            } else {
                Color(nsColor: .windowBackgroundColor)
            }
        }
    }

    private var alignment: Alignment {
        guard let note = entry.note else { return .center }
        return [.leading, .center, .trailing][note.hAlignment]
    }
    
    private var textAlignment: TextAlignment {
        guard let note = entry.note else { return .center }
        return [.leading, .center, .trailing][note.hAlignment]
    }
}
