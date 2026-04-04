import SwiftData
import SwiftUI

struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThuleProduct.createdAt, order: .reverse) private var products: [ThuleProduct]
    @State private var viewModel = ProductListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if products.isEmpty {
                    EmptyStateView()
                } else {
                    listContent
                }
            }
            .background(ThuleTheme.background)
            .navigationTitle(String(localized: "Thule Keys"))
            .searchable(text: $viewModel.searchText, prompt: String(localized: "Search by key code, name, or type"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddForm) {
                ProductFormView()
            }
            .navigationDestination(for: UUID.self) { productID in
                if let product = products.first(where: { $0.id == productID }) {
                    ProductDetailView(product: product)
                }
            }
            .tint(.thuleBlue)
        }
    }

    private var listContent: some View {
        List {
            // Segmented control
            Picker(String(localized: "View"), selection: $viewModel.listMode) {
                ForEach(ListMode.allCases, id: \.self) { mode in
                    Text(mode.displayName)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 16, trailing: 16))

            switch viewModel.listMode {
            case .byProduct:
                byProductSection
            case .byKey:
                KeyGroupedListView(
                    groups: viewModel.groupedByKeyCode(from: products),
                    onDelete: { viewModel.delete($0, in: modelContext) },
                    onDuplicate: { viewModel.duplicate($0, in: modelContext) },
                    shareText: { viewModel.shareText(for: $0) }
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(ThuleTheme.background)
    }

    private var byProductSection: some View {
        ForEach(viewModel.filteredProducts(from: products)) { product in
            NavigationLink(value: product.id) {
                ProductRowView(product: product)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.delete(product, in: modelContext)
                } label: {
                    Label(String(localized: "Delete"), systemImage: "trash")
                }
            }
            .contextMenu {
                Button {
                    viewModel.duplicate(product, in: modelContext)
                } label: {
                    Label(String(localized: "Duplicate"), systemImage: "doc.on.doc")
                }
                ShareLink(item: viewModel.shareText(for: product))
            }
        }
    }
}

#Preview("With Data") {
    ProductListView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Empty") {
    ProductListView()
        .modelContainer(for: ThuleProduct.self, inMemory: true)
}
