import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    
    // createdAt 순으로 정렬
    @Query(sort: \GlazeCollection.createdAt) private var collections: [GlazeCollection]
    
    // 시스템 폴더(Drafts) 찾는 쿼리
    @Query(filter: #Predicate<GlazeFolder> { $0.isDefault == true }) private var defaultFolders: [GlazeFolder]
    
    @Binding var selection: SidebarSelection?
    @Binding var editingNote: GlazeNote?
    
    // MARK: - Creation Sheet State
    @State private var creationType: CreationType?
    @State private var targetCollection: GlazeCollection?
    
    // MARK: - Disclosure State
    @State private var expandedCollections: Set<PersistentIdentifier> = []
    
    // "General"을 제외한 사용자 컬렉션만 필터링
    private var userCollections: [GlazeCollection] {
        collections.filter { $0.name != "General" }
    }
    
    var body: some View {
        List(selection: $selection) {
            // MARK: - 1. Special Sections (Recent & Drafts)
            Section {
                // 🕒 1. Recent
                NavigationLink(value: SidebarSelection.recents) {
                    Label("Recents", systemImage: "clock")
                }
                
                // 📥 2. Drafts (기존 로직 유지)
                NavigationLink(value: SidebarSelection.drafts) {
                    Label("Drafts", systemImage: "tray.full")
                }
                
                // ⭐️ 3. Favorites (추가됨)
                NavigationLink(value: SidebarSelection.favorites) {
                    Label("Favorites", systemImage: "star") // 아이콘 변경
                }
            }
            
            // MARK: - 2. User Collections
            Section("Collections") {
                ForEach(userCollections) { collection in
                    DisclosureGroup(
                        isExpanded: bindingForCollection(collection)
                    ) {
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
                    } label: {
                        Label(collection.name, systemImage: "folder.fill")
                    }
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
                collections: collections,
                onCommit: { name, selectedCol in
                    handleCreation(name: name, collection: selectedCol)
                }
            )
        }
        .onAppear {
            // 앱 시작 시 기존 컬렉션들은 닫아둘지, 열어둘지 결정 (여기선 기존 상태 유지 또는 초기화)
            // 필요한 경우 여기서 초기화 로직 추가
        }
    }
    
    private func createQuickNote() {
        // 1. Drafts 폴더 찾기 시도
        let drafts: GlazeFolder
        
        if let found = defaultFolders.first {
            drafts = found
        } else {
            // [수정] Drafts 폴더가 없으면 즉시 복구(생성) 로직 실행
            print("🚨 Drafts 폴더가 없어 새로 생성합니다.")
            
            // 1-1. General 컬렉션 확보
            let colFetch = FetchDescriptor<GlazeCollection>(predicate: #Predicate { $0.name == "General" })
            let generalCollection: GlazeCollection
            
            if let existingCol = try? modelContext.fetch(colFetch).first {
                generalCollection = existingCol
            } else {
                let newCol = GlazeCollection(name: "General")
                modelContext.insert(newCol)
                generalCollection = newCol
            }
            
            // 1-2. Drafts 폴더 생성
            let newDrafts = GlazeFolder(
                name: "Drafts",
                systemImage: "tray.full",
                isPinned: true,
                isDefault: true // 핵심: Default 설정
            )
            newDrafts.collection = generalCollection
            
            modelContext.insert(newDrafts)
            
            // 1-3. 즉시 저장하여 ID 확보
            do {
                try modelContext.save()
                drafts = newDrafts
            } catch {
                print("❌ 폴더 생성 실패: \(error)")
                return
            }
        }
        
        // 2. 노트 생성 및 이동
        let newNote = GlazeNote()
        newNote.folder = drafts
        modelContext.insert(newNote)
        
        // 3. UI 강제 갱신 및 선택
        // 약간의 딜레이를 주어 쿼리가 갱신된 후 선택되도록 함
        selection = .drafts
        editingNote = newNote
        
        try? modelContext.save()
    }
    
    // MARK: - Disclosure Binding
    private func bindingForCollection(_ collection: GlazeCollection) -> Binding<Bool> {
        let id = collection.persistentModelID
        return Binding(
            get: { expandedCollections.contains(id) },
            set: { isExpanded in
                if isExpanded {
                    expandedCollections.insert(id)
                } else {
                    expandedCollections.remove(id)
                }
            }
        )
    }
    
    // MARK: - Actions
    private func openCreationSheet(type: CreationType, target: GlazeCollection?) {
        targetCollection = target
        creationType = type
    }
    
    private func handleCreation(name: String, collection: GlazeCollection?) {
        switch creationType {
        case .collection:
            let newCollection = GlazeCollection(name: name)
            modelContext.insert(newCollection)
            // [수정] 새 컬렉션 생성 즉시 확장 목록에 추가 (UI 갱신 유도)
            try? modelContext.save() // ID 생성을 위해 저장
            expandedCollections.insert(newCollection.persistentModelID)
            
        case .folder:
            guard let parent = collection else { return }
            let newFolder = GlazeFolder(name: name, systemImage: "folder")
            newFolder.collection = parent
            modelContext.insert(newFolder)
            // 폴더 생성 시 해당 컬렉션이 닫혀있다면 열기
            expandedCollections.insert(parent.persistentModelID)
            selection = .folder(newFolder) // 생성된 폴더 자동 선택
            
        case .none:
            break
        }
        
        try? modelContext.save()
        creationType = nil
    }
    
    private func deleteCollection(_ collection: GlazeCollection) {
        modelContext.delete(collection)
        try? modelContext.save()
        selection = nil
    }
    
    private func deleteFolder(_ folder: GlazeFolder) {
        guard !folder.isDefault else { return }
        let deletingID = folder.persistentModelID
        modelContext.delete(folder)
        try? modelContext.save()
        
        // 현재 선택된 폴더가 삭제된 폴더면 선택 해제
        if case .folder(let selectedFolder) = selection, selectedFolder.persistentModelID == deletingID {
            selection = nil
        }
    }
}
