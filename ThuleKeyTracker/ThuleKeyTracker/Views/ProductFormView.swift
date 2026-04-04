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
            ScrollView {
                VStack(spacing: ThuleTheme.sectionSpacing) {
                    keyCodeHero
                    keyCodeInput
                    productSection
                    detailsSection
                }
                .padding(.horizontal, ThuleTheme.horizontalPadding)
                .padding(.bottom, 32)
            }
            .background(ThuleTheme.background)
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

    private var keyCodeHero: some View {
        VStack(spacing: 12) {
            Text(String(localized: "Live Preview").uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            KeyCodeBadge(code: viewModel.formattedKeyCode, style: .formPreview)
                .opacity(viewModel.canSave ? 1 : 0.3)

            if viewModel.canSave {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(.thuleBlue)
                    Text(String(localized: "Valid Format").uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.thuleBlue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thuleBlue.opacity(0.12), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, ThuleTheme.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                .fill(ThuleTheme.card)
                .overlay {
                    RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                        .strokeBorder(ThuleTheme.separator.opacity(0.5), lineWidth: 0.5)
                }
        }
    }

    private var keyCodeInput: some View {
        ThuleSection("Key Code", footer: "The code is usually engraved on the key or lock face.") {
            ThuleRow(showDivider: false) {
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "e.g. 125 or N125"), text: $viewModel.keyCodeInput)
                        .keyboardType(.numberPad)
                        .font(.body.monospaced())
                }
            }

            if viewModel.showRangeWarning {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(String(localized: "Outside standard Thule range (N001\u{2013}N250)"))
                        .font(.caption)
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, ThuleTheme.cardPadding)
                .padding(.bottom, 12)
            }
        }
    }

    private var productSection: some View {
        ThuleSection("Product") {
            ThuleRow(showDivider: false) {
                Picker(selection: $viewModel.productType) {
                    ForEach(ProductType.allCases) { type in
                        Label(type.displayName, systemImage: type.sfSymbol)
                            .tag(type)
                    }
                } label: {
                    HStack(spacing: 12) {
                        ProductTypeIcon(productType: viewModel.productType, size: 32)
                        Text(String(localized: "Product Type"))
                    }
                }
            }
            if viewModel.showCustomProductName {
                ThuleRow(showDivider: false) {
                    TextField(String(localized: "Product name"), text: $viewModel.customProductName)
                }
            }
        }
    }

    private var detailsSection: some View {
        ThuleSection("Details") {
            ThuleRow {
                HStack {
                    Text(String(localized: "Nickname"))
                    Spacer()
                    TextField(String(localized: "optional"), text: $viewModel.nickname)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.thuleBlue)
                }
            }
            ThuleRow {
                HStack {
                    Text(String(localized: "Locks"))
                    Spacer()
                    Stepper(
                        "\(viewModel.numberOfLocks)",
                        value: $viewModel.numberOfLocks,
                        in: 1...20
                    )
                }
            }
            ThuleRow(showDivider: false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Notes"))
                    TextField(String(localized: "Add details about location or usage (optional)"), text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
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
