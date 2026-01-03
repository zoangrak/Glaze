import Foundation

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
