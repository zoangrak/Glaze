import WidgetKit
import SwiftUI

@main
struct GlazeWidget: Widget {
    let kind: String = "GlazeWidget"

    var body: some WidgetConfiguration {
        // ✨ AppIntentConfiguration을 써야 '편집' 기능이 생깁니다.
        AppIntentConfiguration(
            kind: kind,
            intent: GlazeConfigurationIntent.self, // 방금 만든 설정
            provider: Provider() // 방금 만든 엔진
        ) { entry in
            GlazeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Glaze Memo")
        .description("원하는 메모를 바탕화면에 띄워보세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
