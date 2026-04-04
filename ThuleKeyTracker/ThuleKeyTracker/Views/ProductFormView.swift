import SwiftData
import SwiftUI

struct ProductFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProductFormViewModel

    init(editing product: ThuleProduct? = nil) {
        _viewModel = State(initialValue: product.map {
            ProductFormViewModel(editing: $0)
        } ?? ProductFormViewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                keyCodeSection
                productSection
                detailsSection
            }
            .navigationTitle(viewModel.isEditing
                ? String(localized: "Edit Product")
                : String(localized: "Add Product"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        viewModel.save(in: modelContext)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .tint(.thuleBlue)
        }
    }

    private var keyCodeSection: some View {
        Section {
            VStack(spacing: 16) {
                KeyCodeBadge(
                    code: viewModel.formattedKeyCode,
                    style: .formPreview
                )
                .opacity(viewModel.canSave ? 1 : 0.35)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                TextField(String(localized: "Key code (e.g. 125 or N125)"), text: $viewModel.keyCodeInput)
                    .keyboardType(.numberPad)
                    .font(.body.monospaced())
                    .textFieldStyle(.roundedBorder)

                if viewModel.showRangeWarning {
                    Label(
                        String(localized: "Outside standard Thule range (N001\u{2013}N250)"),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Key Code")
        }
    }

    private var productSection: some View {
        Section {
            Picker(String(localized: "Product Type"), selection: $viewModel.productType) {
                ForEach(ProductType.allCases) { type in
                    Label(type.displayName, systemImage: type.sfSymbol)
                        .tag(type)
                }
            }

            if viewModel.showCustomProductName {
                TextField(String(localized: "Product name"), text: $viewModel.customProductName)
            }
        } header: {
            Text("Product")
        }
    }

    private var detailsSection: some View {
        Section {
            TextField(String(localized: "Nickname (optional)"), text: $viewModel.nickname)

            Stepper(
                String(localized: "Locks: \(viewModel.numberOfLocks)"),
                value: $viewModel.numberOfLocks,
                in: 1...20
            )

            TextField(String(localized: "Notes (optional)"), text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Details")
        }
    }
}

#Preview("Add") {
    ProductFormView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Edit") {
    ProductFormView(editing: PreviewSampleData.sampleProducts.first!)
        .modelContainer(PreviewSampleData.container)
}
