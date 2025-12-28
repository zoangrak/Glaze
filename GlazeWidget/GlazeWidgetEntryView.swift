import SwiftUI
import WidgetKit

struct GlazeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let group = entry.group {
                // 📝 1. 메모 내용 표시 (순수 텍스트)
                VStack(alignment: .leading, spacing: 6) {
                    Text(group.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text(group.content)
                        .font(.system(size: 13))
                        .lineLimit(nil) // 줄 수 제한 없이 꽉 차게
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                // 📭 2. 선택된 메모 없을 때
                VStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("메모를 선택하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(nsColor: .windowBackgroundColor)
        }
    }
}
