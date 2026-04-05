import SwiftData
import SwiftUI

struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \ThuleProduct.createdAt, order: .reverse) private var products: [ThuleProduct]
    @State private var viewModel = ProductListViewModel()
    @Namespace private var segmentAnimation

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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("THULE KEYS")
                        .font(ThuleTheme.titleFont(size: 18))
                        .tracking(1.5)
                }
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
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: String(localized: "Search by key code, name, or type"))
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
            segmentedControl
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))

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

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(ListMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        viewModel.listMode = mode
                    }
                } label: {
                    Text(mode.displayName)
                        .font(ThuleTheme.labelFont(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if viewModel.listMode == mode {
                                Capsule()
                                    .fill(.thuleBlue)
                                    .matchedGeometryEffect(id: "activeSegment", in: segmentAnimation)
                            }
                        }
                        .foregroundStyle(viewModel.listMode == mode ? .white : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(ThuleTheme.segmentedTrack)
        )
    }

    private var byProductSection: some View {
        ForEach(viewModel.filteredProducts(from: products)) { product in
            ZStack {
                NavigationLink(value: product.id) { EmptyView() }
                    .opacity(0)
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
