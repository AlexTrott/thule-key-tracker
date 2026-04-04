import Foundation
import SwiftData
import Testing
@testable import ThuleKeyTracker

@Suite(.serialized)
struct ExportImportTests {

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: ThuleProduct.self,
            configurations: config
        )
    }

    @Test @MainActor func exportProducesValidJSON() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let product = ThuleProduct(
            productType: .roofBox,
            keyCode: "N125",
            nickname: "Test Box"
        )
        context.insert(product)

        let products = try context.fetch(FetchDescriptor<ThuleProduct>())
        let data = try ExportImport.exportJSON(from: products)
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        #expect(json?.count == 1)
        #expect(json?.first?["keyCode"] as? String == "N125")
    }

    @Test @MainActor func importRoundTrips() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let original = ThuleProduct(
            productType: .skiCarrier,
            keyCode: "N042",
            nickname: "Ski Rack",
            notes: "On the Volvo",
            numberOfLocks: 2
        )
        context.insert(original)

        let products = try context.fetch(FetchDescriptor<ThuleProduct>())
        let data = try ExportImport.exportJSON(from: products)

        let imported = try ExportImport.importJSON(from: data)
        #expect(imported.count == 1)
        #expect(imported.first?.keyCode == "N042")
        #expect(imported.first?.productType == .skiCarrier)
        #expect(imported.first?.nickname == "Ski Rack")
        #expect(imported.first?.numberOfLocks == 2)
        #expect(imported.first?.id != original.id)
    }

    @Test func importRejectsInvalidJSON() {
        let garbage = Data("not json".utf8)
        #expect(throws: (any Error).self) {
            try ExportImport.importJSON(from: garbage)
        }
    }
}
