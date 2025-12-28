import SwiftUI
import AppKit

struct EditorView: NSViewRepresentable {
    var note: GlazeNote
    var onChange: (GlazeNote) -> Void
    
    func makeNSView(context: Context) -> NSTextView {
        let tv = NSTextView()
        tv.isRichText = false
        tv.allowsUndo = true
        tv.backgroundColor = .clear
        
        tv.string = note.content
        tv.font = .systemFont(ofSize: CGFloat(note.theme.bodySize))
        
        tv.delegate = context.coordinator
        tv.autoresizingMask = [.width, .height]
        
        return tv
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != note.content {
            nsView.string = note.content
        }
        
        let targetSize = CGFloat(note.theme.bodySize)
        if nsView.font?.pointSize != targetSize {
            nsView.font = .systemFont(ofSize: targetSize)
        }

        context.coordinator.parentNote = note
        context.coordinator.onChange = onChange
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parentNote: note, onChange: onChange)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parentNote: GlazeNote
        var onChange: (GlazeNote) -> Void

        init(parentNote: GlazeNote, onChange: @escaping (GlazeNote) -> Void) {
            self.parentNote = parentNote
            self.onChange = onChange
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            var updatedNote = parentNote
            updatedNote.content = tv.string
            onChange(updatedNote)
            self.parentNote = updatedNote
        }
    }
}
