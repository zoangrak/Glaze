import SwiftUI
import AppKit

struct EditorView: NSViewRepresentable {
    let group: GlazeGroup
    let onChange: (GlazeGroup) -> Void

    func makeNSView(context: Context) -> NSTextView {
        let tv = NSTextView()
        tv.string = group.content
        tv.font = .systemFont(ofSize: group.theme.bodySize)
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        return tv
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != group.content {
            nsView.string = group.content
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(group: group, onChange: onChange)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var group: GlazeGroup
        let onChange: (GlazeGroup) -> Void

        init(group: GlazeGroup, onChange: @escaping (GlazeGroup) -> Void) {
            self.group = group
            self.onChange = onChange
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            group.content = tv.string
            onChange(group)
        }
    }
}

