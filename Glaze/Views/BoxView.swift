import SwiftUI

public struct BoxView: View {
    let note: GlazeNote
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(Color(hex: note.theme.accentColorHex), lineWidth: 2)
            .overlay(
                Text(note.content)
                    .padding()
                    .foregroundStyle(.primary)
            )
    }
}
