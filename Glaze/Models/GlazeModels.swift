import Foundation
import SwiftUI

// MARK: - Theme
public struct GlazeTheme: Codable, Hashable, Sendable {
    public var accentColorHex: String
    public var bodySize: Double
    
    public init(accentColorHex: String = "#00C7BE", bodySize: Double = 16) {
        self.accentColorHex = accentColorHex
        self.bodySize = bodySize
    }
}

// MARK: - Note (단일 메모)
public struct GlazeNote: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var content: String
    public var theme: GlazeTheme
    public var createdAt: Date
    
    // 제목 계산 (앱 내부 사용용)
    public var title: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "New Note" }
        let firstLine = trimmed.components(separatedBy: .newlines).first ?? ""
        return String(firstLine.prefix(50))
    }
    
    public init(
        id: UUID = UUID(),
        content: String = "",
        theme: GlazeTheme = GlazeTheme(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.theme = theme
        self.createdAt = createdAt
    }
}

// MARK: - Group (폴더)
public struct GlazeGroup: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var notes: [GlazeNote]
    
    public init(
        id: UUID = UUID(),
        name: String,
        notes: [GlazeNote] = []
    ) {
        self.id = id
        self.name = name
        self.notes = notes
    }
}
