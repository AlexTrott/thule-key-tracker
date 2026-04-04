import SwiftData
import SwiftUI

struct ProductDetailView: View {
    let product: ThuleProduct
    @State private var showingEditForm = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text(product.keyCode)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                    Text(product.displayName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }

            Section {
                Label(product.productType.displayName, systemImage: product.productType.sfSymbol)
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
