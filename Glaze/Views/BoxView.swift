import SwiftUI

public struct BoxView: View {
    let group: GlazeGroup

    public var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(Color(group.theme.accentColorHex), lineWidth: 2)
            .overlay(
                Text(group.content)
                    .padding()
            )
    }
}
