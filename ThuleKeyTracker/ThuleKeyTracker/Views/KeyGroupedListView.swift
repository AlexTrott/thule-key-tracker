import SwiftData
import SwiftUI

struct KeyGroupedListView: View {
    let groups: [KeyGroup]
    var onDelete: ((ThuleProduct) -> Void)?
    var onDuplicate: ((ThuleProduct) -> Void)?
    var shareText: ((ThuleProduct) -> String)?

    var body: some View {
        ForEach(groups) { group in
            Section {
                ForEach(group.products) { product in
                    NavigationLink(value: product.id) {
                        HStack(spacing: 12) {
                            ProductTypeIcon(productType: product.productType, size: 14)
                            Text(product.displayName)
                                .font(.body.weight(.medium))
                        }
                    }
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
                KeyCodeBadge(code: group.keyCode, style: .groupHeader)
                    .padding(.vertical, 2)
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
    }
    .modelContainer(PreviewSampleData.container)
}
