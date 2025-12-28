import SwiftUI
import WidgetKit

struct GlazeWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let note = entry.note {
                Text(note.content)
                    .font(.system(size: 13))
                    .lineSpacing(3)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .overlay(alignment: .topLeading) {
                        if note.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("빈 메모")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("작성된 메모가 없습니다")
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
