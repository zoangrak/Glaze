import SwiftUI
import SwiftData

struct MainScene: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: SidebarSelection? = .recents
    @State private var selectedNoteId: UUID?
    @State private var editingNote: GlazeNote?
    @State private var isInspectorPresented: Bool = true
    @State private var viewMode: ViewMode = .list

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, editingNote: $editingNote)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            ZStack {
                if let note = editingNote {
                    EditorView(note: note) {
                        withAnimation { editingNote = nil }
                    }
                } else {
                    switch selection {
                    case .recents:
                        Recents(selectedNoteId: $selectedNoteId, editingNote: $editingNote, viewMode: viewMode)
                    case .drafts:
                        EmptyView()
                    case .favorites:
                        Favorites(selectedNoteId: $selectedNoteId, editingNote: $editingNote, viewMode: viewMode)
                    case .folder(let folder):
                        BrowserView(
                            folder: folder,
                            selectedId: $selectedNoteId,
                            editingNote: $editingNote,
                            viewMode: viewMode
                        )
                    case .none:
                        ContentUnavailableView("Select a Folder", systemImage: "sidebar.left")
                    }
                }
            }
            // ✅ 1. 네이티브 타이틀 설정
            .navigationTitle(currentSectionTitle)
            // ✅ 2. 서브타이틀 추가 (SF Symbols 앱 스타일의 핵심)
            // 부제목이 있으면 macOS가 자동으로 '타이틀+서브타이틀'을 묶어서 왼쪽에 예쁘게 배치합니다.
//            .navigationSubtitle(currentSubtitle)
            
            .toolbar {
                ToolbarItem {
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.systemImage)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                ToolbarItemGroup {
                    Button {
                        isInspectorPresented.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                    .help("Toggle Inspector")
                }
            }
        }
        .inspector(isPresented: $isInspectorPresented) {
            Group {
                if let note = editingNote {
                    InspectorView(note: note)
                } else {
                    EmptyView()
                }
            }
            .inspectorColumnWidth(min: 350, ideal: 400)
        }
        .onAppear {
            initializeDefaults()
        }
    }

    // MARK: - Default Data Initialization
    private func initializeDefaults() {
        do {
            // 1. General 컬렉션 확인
            let colDescriptor = FetchDescriptor<GlazeCollection>(predicate: #Predicate { $0.name == "General" })
            let generalCollection: GlazeCollection
            
            if let existing = try modelContext.fetch(colDescriptor).first {
                generalCollection = existing
            } else {
                let new = GlazeCollection(name: "General")
                modelContext.insert(new)
                generalCollection = new
            }
            
            // 2. Drafts 폴더 확인 (쿼리 조건 단순화하지 말고 정확하게 유지)
            let folderDescriptor = FetchDescriptor<GlazeFolder>(
                predicate: #Predicate { $0.isDefault == true }
            )
            let folders = try modelContext.fetch(folderDescriptor)
            
            if folders.isEmpty {
                print("⚠️ Drafts 폴더가 없습니다. 생성을 시작합니다.")
                let drafts = GlazeFolder(
                    name: "Drafts",
                    systemImage: "tray.full",
                    isPinned: true,
                    isDefault: true
                )
                drafts.collection = generalCollection // 관계 연결
                modelContext.insert(drafts)
                
                // 변경사항 저장
                try modelContext.save()
                print("✅ Drafts 폴더 생성 완료")
            }
            
            // 3. 사용자 컬렉션 최소 1개 보장
                let userCollections = try modelContext.fetch(FetchDescriptor<GlazeCollection>(predicate: #Predicate { $0.name != "General" }))
                if userCollections.isEmpty {
                    let starter = GlazeCollection(name: "New Collection")
                    modelContext.insert(starter)
                    try modelContext.save()
                }
        } catch {
            print("❌ 초기화 실패: \(error)")
        }
    }
    
    private var currentSectionTitle: String {
        switch selection {
        case .recents:
            return "Recents"
        case .drafts:
            return "Drafts"
        case .favorites:
            return "Favorites"
        case .folder(let folder):
            return folder.name
        case .none:
            return ""
        }
    }
}


