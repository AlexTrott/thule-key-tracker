import Foundation
import SwiftData

@Model
final class ThuleProduct {
    var id: UUID
    var productType: ProductType
    var customProductName: String?
    var keyCode: String
    var nickname: String?
    var notes: String?
    var numberOfLocks: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        productType: ProductType,
        customProductName: String? = nil,
        keyCode: String,
        nickname: String? = nil,
        notes: String? = nil,
        numberOfLocks: Int = 1,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.productType = productType
        self.customProductName = customProductName
        self.keyCode = keyCode
        self.nickname = nickname
        self.notes = notes
        self.numberOfLocks = numberOfLocks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var displayName: String {
        if productType == .other, let custom = customProductName, !custom.isEmpty {
            return custom
        }
        return nickname ?? productType.displayName
    }
}
