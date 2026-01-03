import SwiftUI
import SwiftData

struct CreationSheet: View {
    let type: CreationType
    var initialCollection: GlazeCollection?
    var onCommit: (String, GlazeCollection?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \GlazeCollection.createdAt) private var collections: [GlazeCollection]
        
    @State private var name: String = ""
    @State private var selectedCollection: GlazeCollection?

    private var validCollections: [GlazeCollection] {
        collections.filter { $0.name != "General" }
    }
    
    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Title
            VStack(spacing: 8) {
                Text(type == .collection ? "New Collection" : "New Folder")
                    .font(.headline)

                Text(descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // MARK: - Form
            VStack(spacing: 12) {

                if type == .folder {
                    HStack {
                        Text("Collection:")
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .trailing)

                        Picker("", selection: $selectedCollection) {
                            if validCollections.isEmpty {
                                Text("사용자 컬렉션 없음").tag(nil as GlazeCollection?)
                            } else {
                                if selectedCollection == nil {
                                    Text("선택해주세요").tag(nil as GlazeCollection?)
                                }
                                ForEach(validCollections) { collection in
                                    Text(collection.name).tag(collection as GlazeCollection?)
                                }
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                }

                HStack {
                    Text("Name:")
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .trailing)

                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { if !okDisabled { commit() } }
                }
            }
            .padding(.horizontal)

            // MARK: - Buttons
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("OK") {
                    commit()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(okDisabled)
            }
        }
        .padding()
        .frame(width: 420)
        .onAppear {
            if type == .folder {
                if let initial = initialCollection { selectedCollection = initial }
                else { selectedCollection = validCollections.first }
            }
        }
    }

    // MARK: - Helpers
    private var okDisabled: Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        if type == .folder && selectedCollection == nil { return true }
        return false
    }

    private var descriptionText: String {
        type == .collection
        ? "Create a new collection to organize folders."
        : "Create a new folder inside a collection."
    }
    
    private func commit() {
        onCommit(name, selectedCollection)
        dismiss()
    }
}
