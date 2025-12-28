import Foundation
import SwiftUI

public struct GlazeTheme: Codable, Hashable {
    public var accentColorHex: String = "#00C7BE"
    public var bodySize: CGFloat = 16
    public init() {}
}

public struct GlazeGroup: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var content: String
    public var theme: GlazeTheme

    public init(
        id: UUID = UUID(),
        name: String,
        content: String = "",
        theme: GlazeTheme = GlazeTheme(),
    ) {
        self.id = id
        self.name = name
        self.content = content
        self.theme = theme
    }
}


public struct GlazeSection: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var notes: [GlazeGroup]

    public init(
        id: UUID = UUID(),
        name: String,
        notes: [GlazeGroup] = []
    ) {
        self.id = id
        self.name = name
        self.notes = notes
    }
}

