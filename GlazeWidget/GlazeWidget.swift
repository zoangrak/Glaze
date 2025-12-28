import WidgetKit
import SwiftUI

@main
struct GlazeWidget: Widget {
    let kind: String = "GlazeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: GlazeConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            GlazeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Glaze Memo")
        .description("원하는 메모를 바탕화면에 띄워보세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
