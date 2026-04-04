import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [ThuleProduct]
    @State private var showingResetConfirmation = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importError: String?
    @State private var showingImportError = false

    var body: some View {
        Form {
            Section {
                LabeledContent(String(localized: "Products"), value: "\(products.count)")
                let uniqueKeys = Set(products.map(\.keyCode)).count
                LabeledContent(String(localized: "Unique Keys"), value: "\(uniqueKeys)")
            } header: {
                Text("Summary")
            }

            Section {
                Button(String(localized: "Export Data")) {
                    showingExporter = true
                }
                Button(String(localized: "Import Data")) {
                    showingImporter = true
                }
            } header: {
                Text("Backup")
            }

            Section {
                Button(String(localized: "Delete All Data"), role: .destructive) {
                    showingResetConfirmation = true
                }
            } header: {
                Text("Reset")
            }

            Section {
                LabeledContent(String(localized: "Version"), value: appVersion)
            } header: {
                Text("About")
            } footer: {
                Text("Thule key codes follow the pattern N001\u{2013}N250. This app is not affiliated with Thule Group.")
            }
        }
        .navigationTitle(String(localized: "Settings"))
        .tint(.thuleBlue)
        .confirmationDialog(
            String(localized: "Delete All Data?"),
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete Everything"), role: .destructive) {
                deleteAllProducts()
            }
        } message: {
            Text("This will permanently remove all your saved products. This cannot be undone.")
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: JSONExportDocument(products: products),
            contentType: .json,
            defaultFilename: "thule-keys-backup"
        ) { _ in }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result)
        }
        .alert(
            String(localized: "Import Failed"),
            isPresented: $showingImportError
        ) {
            Button(String(localized: "OK")) {}
        } message: {
            Text(importError ?? "")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func deleteAllProducts() {
        for product in products {
            modelContext.delete(product)
        }
    }

    private func handleImport(_ result: Result<URL, any Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                let imported = try ExportImport.importJSON(from: data)
                for product in imported {
                    modelContext.insert(product)
                }
            } catch {
                importError = error.localizedDescription
                showingImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showingImportError = true
        }
    }
}

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(products: [ThuleProduct]) {
        self.data = (try? ExportImport.exportJSON(from: products)) ?? Data()
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewSampleData.container)
}
