import Foundation
import SwiftData
import SwiftUI

enum SidebarSelection: Hashable {
    case recents
    case drafts
    case favorites
    case folder(GlazeFolder)
}

enum CreationType: Identifiable {
    case collection
    case folder

    var id: String {
        switch self {
        case .collection:
            return "collection"
        case .folder:
            return "folder"
        }
    }
}

enum ViewMode: String, CaseIterable {
    case list = "List"
    case gallery = "Gallery"
    
    var systemImage: String {
        switch self {
        case .list: return "list.bullet"
        case .gallery: return "square.grid.2x2"
        }
    }
}
