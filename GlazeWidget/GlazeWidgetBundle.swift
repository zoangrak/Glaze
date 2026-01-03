import WidgetKit
import SwiftUI

@main
struct GlazeWidgetBundle: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "GlazeWidget",
            intent: ConfigurationIntent.self, // 아래 WidgetIntent.swift에서 변경한 이름 사용
            provider: WidgetProvider()
        ) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Glaze")
        .description("당신의 영감을 바탕화면에 디자인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
