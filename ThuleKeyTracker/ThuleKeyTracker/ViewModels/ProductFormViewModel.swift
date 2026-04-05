import Foundation
import Observation
import SwiftData

@Observable
final class ProductFormViewModel {
    var productType: ProductType = .roofBox
    var customProductName = ""
    var keyCodeInput = ""
    var nickname = ""
    var notes = ""
    var numberOfLocks = 1

    private var editingProduct: ThuleProduct?

    var isEditing: Bool { editingProduct != nil }

    var formattedKeyCode: String {
        KeyCodeFormatter.displayString(for: keyCodeInput)
    }

    var showRangeWarning: Bool {
        KeyCodeFormatter.isValid(keyCodeInput) && !KeyCodeFormatter.isInStandardRange(keyCodeInput)
    }

    var canSave: Bool {
        KeyCodeFormatter.isValid(keyCodeInput)
    }

    var showCustomProductName: Bool {
        productType == .other
    }

    init() {}

    init(editing product: ThuleProduct) {
        self.editingProduct = product
        self.productType = product.productType
        self.customProductName = product.customProductName ?? ""
        self.keyCodeInput = product.keyCode.hasPrefix("N") ? String(product.keyCode.dropFirst()) : product.keyCode
        self.nickname = product.nickname ?? ""
        self.notes = product.notes ?? ""
        self.numberOfLocks = product.numberOfLocks
    }

    func save(in context: ModelContext) {
        guard let normalisedCode = KeyCodeFormatter.normalise(keyCodeInput) else { return }

        let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        let trimmedCustomName = customProductName.trimmingCharacters(in: .whitespaces)

        if let product = editingProduct {
            product.productType = productType
            product.customProductName = productType == .other ? (trimmedCustomName.isEmpty ? nil : trimmedCustomName) : nil
            product.keyCode = normalisedCode
            product.nickname = trimmedNickname.isEmpty ? nil : trimmedNickname
            product.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            product.numberOfLocks = numberOfLocks
            product.updatedAt = .now
        } else {
            let product = ThuleProduct(
                productType: productType,
                customProductName: productType == .other ? (trimmedCustomName.isEmpty ? nil : trimmedCustomName) : nil,
                keyCode: normalisedCode,
                nickname: trimmedNickname.isEmpty ? nil : trimmedNickname,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                numberOfLocks: numberOfLocks
            )
            context.insert(product)
        }
    }
}
