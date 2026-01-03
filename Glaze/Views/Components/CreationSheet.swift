import SwiftUI

struct CreationSheet: View {
    let type: CreationType

    // 폴더 생성 시 초기 선택될 컬렉션 (없을 수도 있음)
    var initialCollection: GlazeCollection?

    // 피커에 표시할 전체 컬렉션 리스트
    var collections: [GlazeCollection]

    // 완료 시 실행할 클로저 (이름, 선택된 컬렉션)
    var onCommit: (String, GlazeCollection?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedCollection: GlazeCollection?

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
                            ForEach(collections) { collection in
                                if collection.name != "General" {
                                    Text(collection.name)
                                        .tag(collection as GlazeCollection?)
                                }
                            }
                        }
                        .labelsHidden()
                    }
                }

                HStack {
                    Text("Name:")
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .trailing)

                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { commit() }
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
            setupInitialState()
        }
    }

    // MARK: - Helpers

    private var okDisabled: Bool {
        name.isEmpty || (type == .folder && selectedCollection == nil)
    }

    private var descriptionText: String {
        type == .collection
        ? "Create a new collection to organize folders."
        : "Create a new folder inside a collection."
    }

    private func setupInitialState() {
        guard type == .folder else { return }

        if let initial = initialCollection {
            selectedCollection = initial
        } else {
            selectedCollection = collections.first(where: { $0.name != "General" })
        }
    }

    private func commit() {
        guard !name.isEmpty else { return }
        onCommit(name, selectedCollection)
        dismiss()
    }
}
