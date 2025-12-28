import WidgetKit
import SwiftUI

struct GlazeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GlazeWidget", provider: Provider()) { entry in
            Text(entry.text)
        }
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let text: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, text: "Glaze")
    }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .never))
    }
}
