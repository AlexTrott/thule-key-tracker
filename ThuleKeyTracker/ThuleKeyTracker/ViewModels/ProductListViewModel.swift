import Foundation
import Observation
import SwiftData

enum ListMode: CaseIterable {
    case byProduct
    case byKey

    var displayName: String {
        switch self {
        case .byProduct: String(localized: "By Product")
        case .byKey: String(localized: "By Key")
        }
    }
}

struct KeyGroup: Identifiable {
    let keyCode: String
    let products: [ThuleProduct]
    var id: String { keyCode }
}

@Observable
final class ProductListViewModel {
    var searchText = ""
    var listMode: ListMode = .byProduct
    var showingAddForm = false

    func filteredProducts(from products: [ThuleProduct]) -> [ThuleProduct] {
        guard !searchText.isEmpty else { return products }
        let query = searchText.lowercased()
        return products.filter { product in
            product.keyCode.lowercased().contains(query)
            || (product.nickname?.lowercased().contains(query) ?? false)
            || product.productType.displayName.lowercased().contains(query)
            || (product.customProductName?.lowercased().contains(query) ?? false)
        }
    }

    func groupedByKeyCode(from products: [ThuleProduct]) -> [KeyGroup] {
        let filtered = filteredProducts(from: products)
        let grouped = Dictionary(grouping: filtered) { $0.keyCode }
        return grouped
            .map { KeyGroup(keyCode: $0.key, products: $0.value) }
            .sorted { $0.keyCode < $1.keyCode }
    }

    func duplicate(_ product: ThuleProduct, in context: ModelContext) {
        let copy = ThuleProduct(
            productType: product.productType,
            customProductName: product.customProductName,
            keyCode: product.keyCode,
            nickname: product.nickname,
            notes: product.notes,
            numberOfLocks: product.numberOfLocks
        )
        context.insert(copy)
    }

    func delete(_ product: ThuleProduct, in context: ModelContext) {
        context.delete(product)
    }

    func shareText(for product: ThuleProduct) -> String {
        "\(product.displayName) — Key \(product.keyCode)"
    }
}
