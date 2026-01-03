import Foundation
import SwiftData
import SwiftUI

@Model
final class GlazeCollection {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \GlazeFolder.collection)
    var folders: [GlazeFolder] = []
    
    init(name: String = "새 컬렉션") {
        self.name = name
        self.createdAt = Date()
    }
}

@Model
final class GlazeFolder {
    var name: String
    var systemImage: String
    var isPinned: Bool
    var isDefault: Bool
    var createdAt: Date
    
    var collection: GlazeCollection?
    @Relationship(deleteRule: .cascade, inverse: \GlazeNote.folder)
    var notes: [GlazeNote] = []
    
    // init 수정
    init(name: String = "새 폴더", systemImage: String = "folder", isPinned: Bool = false, isDefault: Bool = false) {
        self.name = name
        self.systemImage = systemImage
        self.isPinned = isPinned
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

@Model
final class GlazeNote {
    var id: UUID = UUID()
    var content: String
    var createdAt: Date
    var lastModified: Date
    var isPinned: Bool = false
    
    var folder: GlazeFolder?
    
    // 디자인 속성
    var backgroundColorHex: String = "#FFFFFF"
    var textColorHex: String = "#1C1C1E"
    var cornerRadius: Double = 28.0
    var hAlignment: Int = 1
    var fontSize: Double = 18.0
    var fontWeight: String = "Regular"
    
    init(content: String = "") {
        self.content = content
        self.createdAt = Date()
        self.lastModified = Date()
    }
}

// WidgetNoteEntity는 기존 유지
struct GlazeNoteEntity: Codable, Identifiable, Sendable {
    let id: UUID
    let content: String
    let backgroundColorHex: String
    let textColorHex: String
    let cornerRadius: Double
    let hAlignment: Int
    let fontSize: Double
    let fontWeight: String
}
