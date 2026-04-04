import Foundation

enum ExportImport: Sendable {

    struct ProductDTO: Codable, Sendable {
        let productType: String
        let customProductName: String?
        let keyCode: String
        let nickname: String?
        let notes: String?
        let numberOfLocks: Int
        let createdAt: Date
        let updatedAt: Date
    }

    static func exportJSON(from products: [ThuleProduct]) throws -> Data {
        let dtos = products.map { product in
            ProductDTO(
                productType: product.productType.rawValue,
                customProductName: product.customProductName,
                keyCode: product.keyCode,
                nickname: product.nickname,
                notes: product.notes,
                numberOfLocks: product.numberOfLocks,
                createdAt: product.createdAt,
                updatedAt: product.updatedAt
            )
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(dtos)
    }

    static func importJSON(from data: Data) throws -> [ThuleProduct] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dtos = try decoder.decode([ProductDTO].self, from: data)
        return dtos.map { dto in
            ThuleProduct(
                productType: ProductType(rawValue: dto.productType) ?? .other,
                customProductName: dto.customProductName,
                keyCode: dto.keyCode,
                nickname: dto.nickname,
                notes: dto.notes,
                numberOfLocks: dto.numberOfLocks,
                createdAt: dto.createdAt,
                updatedAt: dto.updatedAt
            )
        }
    }
}
