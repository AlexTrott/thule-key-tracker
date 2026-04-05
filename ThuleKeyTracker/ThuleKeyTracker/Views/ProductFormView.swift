import SwiftData
import SwiftUI

struct ProductFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: ProductFormViewModel
    @FocusState private var keyCodeFocused: Bool
    @State private var showingProductTypePicker = false

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
                    productSection
                    detailsSection
                }
                .padding(.horizontal, ThuleTheme.horizontalPadding)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
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
            .onAppear {
                if !viewModel.isEditing {
                    keyCodeFocused = true
                }
            }
        }
    }

    private var keyCodeHero: some View {
        VStack(spacing: 16) {
            Text("KEY CODE")
                .font(ThuleTheme.labelFont(size: 11))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            // Big editable key code: fixed "N" prefix + digit input
            ZStack {
                // Invisible sizer — always reserves space for "N000"
                Text("N000")
                    .font(ThuleTheme.keyCodeFont(size: 56))
                    .tracking(-2)
                    .hidden()

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("N")
                        .font(ThuleTheme.keyCodeFont(size: 56))
                        .tracking(-2)
                        .foregroundStyle(viewModel.keyCodeInput.isEmpty ? .tertiary : .primary)

                    TextField("___", text: $viewModel.keyCodeInput)
                        .font(ThuleTheme.keyCodeFont(size: 56))
                        .tracking(-2)
                        .keyboardType(.numberPad)
                        .focused($keyCodeFocused)
                        .textFieldStyle(.plain)
                        .fixedSize()
                }
            }
            .frame(height: 68)

            if viewModel.canSave {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(.thuleBlue)
                    Text("VALID FORMAT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.thuleBlue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thuleBlue.opacity(0.12), in: Capsule())
            }

            if viewModel.showRangeWarning {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(String(localized: "Outside standard Thule range (N001\u{2013}N250)"))
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }

            Text("The code is usually engraved on the key or lock face.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, ThuleTheme.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [.white.opacity(0.08), .white.opacity(0.02)]
                                    : [.black.opacity(0.04), .black.opacity(0.01)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.04),
                    radius: 8, y: 2
                )
        }
        .onTapGesture {
            keyCodeFocused = true
        }
    }

    private var productSection: some View {
        ThuleSection("PRODUCT") {
            ThuleRow(showDivider: viewModel.showCustomProductName) {
                Button {
                    showingProductTypePicker = true
                } label: {
                    HStack(spacing: 12) {
                        ProductTypeIcon(productType: viewModel.productType, size: 40)
                        Text(viewModel.productType.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if viewModel.showCustomProductName {
                ThuleRow(showDivider: false) {
                    TextField(String(localized: "Product name"), text: $viewModel.customProductName)
                }
            }
        }
        .sheet(isPresented: $showingProductTypePicker) {
            ProductTypePickerView(selectedType: $viewModel.productType)
        }
    }

    private var detailsSection: some View {
        ThuleSection("DETAILS") {
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
