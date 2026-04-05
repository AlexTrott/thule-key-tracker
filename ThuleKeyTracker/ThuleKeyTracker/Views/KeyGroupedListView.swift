import SwiftData
import SwiftUI

struct KeyGroupedListView: View {
    let groups: [KeyGroup]
    var onDelete: ((ThuleProduct) -> Void)?
    var onDuplicate: ((ThuleProduct) -> Void)?
    var shareText: ((ThuleProduct) -> String)?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ForEach(groups) { group in
            Section {
                ForEach(group.products) { product in
                    ZStack {
                        NavigationLink(value: product.id) { EmptyView() }
                            .opacity(0)
                        HStack(spacing: 14) {
                            ProductTypeIcon(productType: product.productType)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.displayName)
                                    .font(.system(size: 17, weight: .semibold))
                                Text(product.productType.displayName.uppercased())
                                    .font(ThuleTheme.labelFont(size: 12))
                                    .tracking(0.5)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .padding(ThuleTheme.cardPadding)
                        .background {
                            RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                                .fill(ThuleTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: colorScheme == .dark
                                                    ? [.white.opacity(0.08), .white.opacity(0.02)]
                                                    : [.black.opacity(0.06), .black.opacity(0.02)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                                .shadow(
                                    color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                                    radius: 8, y: 2
                                )
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if let onDelete {
                            Button(role: .destructive) {
                                onDelete(product)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                    .contextMenu {
                        if let onDuplicate {
                            Button {
                                onDuplicate(product)
                            } label: {
                                Label(String(localized: "Duplicate"), systemImage: "doc.on.doc")
                            }
                        }
                        if let shareText {
                            ShareLink(item: shareText(product))
                        }
                    }
                }
            } header: {
                HStack(alignment: .firstTextBaseline) {
                    KeyCodeBadge(code: group.keyCode, style: .groupHeader)

                    Spacer()

                    Text("\(group.products.count) \(group.products.count == 1 ? "PRODUCT" : "PRODUCTS")")
                        .font(ThuleTheme.labelFont(size: 12))
                        .tracking(0.8)
                        .foregroundStyle(.thuleBlue)
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
                .textCase(nil)
            }
        }
    }
}

#Preview {
    let groups = [
        KeyGroup(keyCode: "N042", products: Array(PreviewSampleData.sampleProducts.filter { $0.keyCode == "N042" })),
        KeyGroup(keyCode: "N125", products: Array(PreviewSampleData.sampleProducts.filter { $0.keyCode == "N125" })),
    ]
    NavigationStack {
        List {
            KeyGroupedListView(groups: groups)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(ThuleTheme.background)
    }
    .modelContainer(PreviewSampleData.container)
}
