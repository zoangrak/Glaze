import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    
    // ✨ 필터링을 쿼리 단계에서 수행하여 데이터 추가 시 즉시 뷰에 반영
    @Query(
        filter: #Predicate<GlazeCollection> { $0.name != "General" },
        sort: \GlazeCollection.createdAt
    ) private var userCollections: [GlazeCollection]
    
    @Query(filter: #Predicate<GlazeFolder> { $0.isDefault == true }) private var defaultFolders: [GlazeFolder]
    
    @Binding var selection: SidebarSelection?
    @Binding var editingNote: GlazeNote?
    
    @State private var creationType: CreationType?
    @State private var targetCollection: GlazeCollection?
    
    // DisclosureGroup/expandedCollections 제거: Section 기반으로 즉시 반영
    
    var body: some View {
        List(selection: $selection) {
            // MARK: - 1. Special Sections (Recents & Drafts & Favorites)
            Section {
                // 🕒 1. Recent
                NavigationLink(value: SidebarSelection.recents) {
                    Label("Recents", systemImage: "clock")
                }
                
                // 📥 2. Drafts
                NavigationLink(value: SidebarSelection.drafts) {
                    Label("Drafts", systemImage: "tray.full")
                }
                
                // ⭐️ 3. Favorites
                NavigationLink(value: SidebarSelection.favorites) {
                    Label("Favorites", systemImage: "star")
                }
            }
            
            // MARK: - 2. User Collections
            // ✨ 각 컬렉션 자체가 하나의 섹션 헤더가 되도록 구성
            ForEach(userCollections) { collection in
                Section {
                    // 섹션 내용: 해당 컬렉션의 폴더들
                    ForEach(collection.folders) { folder in
                        NavigationLink(value: SidebarSelection.folder(folder)) {
                            Label(folder.name, systemImage: folder.systemImage)
                        }
                        .contextMenu {
                            Button("Delete Folder", systemImage: "trash", role: .destructive) {
                                deleteFolder(folder)
                            }
                        }
                    }
                } header: {
                    // ✨ 섹션 제목: 실제 컬렉션 이름 사용
                    // 우클릭 메뉴도 여기에 부착하여 컬렉션 관리 가능
                    HStack {
                        Text(collection.name)
                            .font(.headline) // 헤더 느낌 강조
                        Spacer()
                    }
                    .background(Color.clear) // 클릭 영역 확보
                    .contextMenu {
                        Button("New Folder") {
                            openCreationSheet(type: .folder, target: collection)
                        }
                        Divider()
                        Button("Delete Collection", role: .destructive) {
                            deleteCollection(collection)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        
        // MARK: - Background Context Menu
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createQuickNote) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
            }
        }
        .contextMenu {
            Button("New Collection") {
                openCreationSheet(type: .collection, target: nil)
            }
            Button("New Folder") {
                openCreationSheet(type: .folder, target: nil)
            }
        }
        .sheet(item: $creationType) { type in
            CreationSheet(
                type: type,
                initialCollection: targetCollection,
                onCommit: { name, selectedCol in
                    handleCreation(name: name, collection: selectedCol)
                }
            )
            .modelContext(modelContext) // ✨ 시트 데이터 연동 필수
        }
    }
    
    // MARK: - Logic Helpers
    
    private func createQuickNote() {
        let drafts: GlazeFolder
        if let found = defaultFolders.first {
            drafts = found
        } else { return } // initializeDefaults에서 보장됨
        
        let newNote = GlazeNote()
        newNote.folder = drafts
        modelContext.insert(newNote)
        try? modelContext.save()
        
        selection = .drafts
        editingNote = newNote
    }
    
    private func openCreationSheet(type: CreationType, target: GlazeCollection?) {
        targetCollection = target
        creationType = type
    }
    
    private func handleCreation(name: String, collection: GlazeCollection?) {
        switch creationType {
        case .collection:
            let newCollection = GlazeCollection(name: name)
            modelContext.insert(newCollection)
            try? modelContext.save()
            // Section 구조이므로 별도 확장 상태 조작 불필요
            
        case .folder:
            guard let parent = collection else { return }
            let newFolder = GlazeFolder(name: name, systemImage: "folder")
            newFolder.collection = parent
            modelContext.insert(newFolder)
            try? modelContext.save()
            
            // 폴더 생성 후 자동 선택
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selection = .folder(newFolder)
            }
            
        case .none: break
        }
        creationType = nil
        targetCollection = nil
    }
    
    private func deleteCollection(_ collection: GlazeCollection) {
        modelContext.delete(collection)
        try? modelContext.save()
        selection = nil
    }
    
    private func deleteFolder(_ folder: GlazeFolder) {
        let id = folder.persistentModelID
        modelContext.delete(folder)
        try? modelContext.save()
        if case .folder(let f) = selection, f.persistentModelID == id { selection = nil }
    }
}
