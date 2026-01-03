import SwiftUI
import SwiftData

struct MainScene: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: SidebarSelection? = .recents
    @State private var selectedNoteId: UUID?
    @State private var editingNote: GlazeNote?

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, editingNote: $editingNote)
                .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        } content: {
            // [수정] editingNote가 있으면 에디터를 최우선으로 표시
            if let note = editingNote {
                EditorView(note: note) {
                    // 닫기 버튼 액션
                    editingNote = nil
                }
            } else {
                // editingNote가 없을 때만 리스트(브라우저) 표시
                switch selection {
                case .recents:
                    Recents(selectedNoteId: $selectedNoteId, editingNote: $editingNote)
                case .drafts:
                    if let draftFolder = try? modelContext.fetch(FetchDescriptor<GlazeFolder>(predicate: #Predicate { $0.isDefault })).first {
                            Draft(folder: draftFolder, selectedNoteId: $selectedNoteId, editingNote: $editingNote)
                        } else {
                            ContentUnavailableView("Drafts Not Found", systemImage: "exclamationmark.triangle")
                        }
                case .favorites:
                    Favorites(selectedNoteId: $selectedNoteId, editingNote: $editingNote)
                    
                case .folder(let folder):
                    BrowserView(
                        folder: folder,
                        selectedId: $selectedNoteId,
                        editingNote: $editingNote
                    )
                    
                case .none:
                    ContentUnavailableView("Select a Folder", systemImage: "sidebar.left")
                }
            }
        } detail: {
            if let note = editingNote {
                InspectorView(note: note)
                    .navigationSplitViewColumnWidth(min: 280, ideal: 320)
            } else {
                ContentUnavailableView("Select a Note", systemImage: "doc.text")
            }
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
            
        } catch {
            print("❌ 초기화 실패: \(error)")
        }
    }
}
