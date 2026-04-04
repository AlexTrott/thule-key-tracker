import SwiftData
import SwiftUI

struct ProductDetailView: View {
    let product: ThuleProduct
    @State private var showingEditForm = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    ProductTypeIcon(productType: product.productType, size: 28)

                    KeyCodeBadge(code: product.keyCode, style: .hero)

                    Text(product.displayName)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            }

            Section {
                Label(product.productType.displayName, systemImage: product.productType.sfSymbol)
                    .foregroundStyle(.thuleBlue)
                if let custom = product.customProductName, product.productType == .other {
                    LabeledContent(String(localized: "Custom Name"), value: custom)
                }
                if let nickname = product.nickname {
                    LabeledContent(String(localized: "Nickname"), value: nickname)
                }
                LabeledContent(String(localized: "Number of Locks"), value: "\(product.numberOfLocks)")
            } header: {
                Text("Product Info")
            }

            if let notes = product.notes, !notes.isEmpty {
                Section {
                    Text(notes)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Notes")
                }
            }

            Section {
                LabeledContent(String(localized: "Added"), value: product.createdAt.formatted(date: .abbreviated, time: .omitted))
                LabeledContent(String(localized: "Updated"), value: product.updatedAt.formatted(date: .abbreviated, time: .omitted))
            } header: {
                Text("Dates")
            }
        }
        .navigationTitle(product.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(String(localized: "Edit")) {
                showingEditForm = true
            }
            .fontWeight(.semibold)
            .foregroundStyle(.thuleBlue)
        }
        .sheet(isPresented: $showingEditForm) {
            ProductFormView(editing: product)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: PreviewSampleData.sampleProducts.first!)
    }
    .modelContainer(PreviewSampleData.container)
}
