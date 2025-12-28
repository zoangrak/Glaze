import AppIntents
import WidgetKit

struct ToggleCompletionIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Completion"
    
    @Parameter(title: "ID")
    var id: String

    init() {}
    init(id: String) { self.id = id }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let uuid = UUID(uuidString: id) {
            GlazeStore().toggleCompletion(id: uuid)
            WidgetCenter.shared.reloadAllTimelines()
        }
        return .result()
    }
}
