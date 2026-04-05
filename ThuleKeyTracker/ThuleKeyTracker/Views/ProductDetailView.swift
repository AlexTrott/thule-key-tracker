import SwiftData
import SwiftUI

struct ProductDetailView: View {
    let product: ThuleProduct
    @State private var showingEditForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: ThuleTheme.sectionSpacing) {
                heroSection
                productInfoSection
                if let notes = product.notes, !notes.isEmpty {
                    notesSection(notes)
                }
                datesSection
            }
            .padding(.horizontal, ThuleTheme.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(ThuleTheme.background)
        .navigationTitle(product.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(String(localized: "Edit")) {
                showingEditForm = true
            }
            .fontWeight(.semibold)
        }
        .sheet(isPresented: $showingEditForm) {
            ProductFormView(editing: product)
        }
        .tint(.thuleBlue)
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ProductTypeIcon(productType: product.productType, size: 56)

            KeyCodeBadge(code: product.keyCode, style: .hero)

            Text(product.productType.displayName.uppercased())
                .font(ThuleTheme.labelFont(size: 13))
                .tracking(1.0)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var productInfoSection: some View {
        ThuleSection("PRODUCT INFO") {
            ThuleRow {
                HStack(spacing: 12) {
                    Image(systemName: product.productType.sfSymbol)
                        .font(.system(size: 16))
                        .foregroundStyle(.thuleBlue)
                        .frame(width: 28, height: 28)
                        .background(.thuleBlue.opacity(0.15), in: Circle())
                    Text(product.productType.displayName)
                        .fontWeight(.medium)
                }
            }
            if let nickname = product.nickname {
                ThuleRow {
                    HStack {
                        Text(String(localized: "Nickname"))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(nickname)
                            .fontWeight(.medium)
                    }
                }
            }
            ThuleRow(showDivider: false) {
                HStack {
                    Text(String(localized: "Number of Locks"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(product.numberOfLocks)")
                        .fontWeight(.medium)
                }
            }
        }
    }

    private func notesSection(_ notes: String) -> some View {
        ThuleSection("NOTES") {
            ThuleRow(showDivider: false) {
                Text(notes)
                    .foregroundStyle(.primary)
            }
        }
    }

    private var datesSection: some View {
        ThuleSection("TIMELINE") {
            ThuleRow {
                HStack {
                    Text(String(localized: "Added"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(product.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.medium)
                }
            }
            ThuleRow(showDivider: false) {
                HStack {
                    Text(String(localized: "Updated"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(product.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: PreviewSampleData.sampleProducts.first!)
    }
    .modelContainer(PreviewSampleData.container)
}
