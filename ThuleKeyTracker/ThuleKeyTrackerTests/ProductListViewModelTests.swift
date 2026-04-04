import Foundation
import SwiftData
import Testing
@testable import ThuleKeyTracker

@Suite(.serialized)
struct ProductListViewModelTests {

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: ThuleProduct.self, configurations: config)
    }

    @MainActor
    private func populate(_ context: ModelContext) {
        let products = [
            ThuleProduct(productType: .roofBox, keyCode: "N125", nickname: "Motion XT"),
            ThuleProduct(productType: .bikeRackTowbar, keyCode: "N125", nickname: "EasyFold"),
            ThuleProduct(productType: .roofBars, keyCode: "N042", nickname: "WingBar"),
            ThuleProduct(productType: .skiCarrier, keyCode: "N200"),
        ]
        for p in products { context.insert(p) }
    }

    // MARK: - Search

    @Test @MainActor func searchFiltersByKeyCode() throws {
        let container = try makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "125"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.keyCode == "N125" })
    }

    @Test @MainActor func searchFiltersByNickname() throws {
        let container = try makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "wing"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 1)
        #expect(filtered.first?.nickname == "WingBar")
    }

    @Test @MainActor func searchFiltersByProductType() throws {
        let container = try makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "ski"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 1)
        #expect(filtered.first?.productType == .skiCarrier)
    }

    @Test @MainActor func emptySearchReturnsAll() throws {
        let container = try makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = ""
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 4)
    }

    // MARK: - Grouping

    @Test @MainActor func groupsByKeyCode() throws {
        let container = try makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        let grouped = vm.groupedByKeyCode(from: all)

        #expect(grouped.count == 3)
        let n125Group = grouped.first { $0.keyCode == "N125" }
        #expect(n125Group?.products.count == 2)
    }

    // MARK: - Duplicate

    @Test @MainActor func duplicateCreatesNewProduct() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let original = ThuleProduct(
            productType: .roofBox,
            keyCode: "N125",
            nickname: "Original",
            notes: "Some notes",
            numberOfLocks: 2
        )
        context.insert(original)

        let vm = ProductListViewModel()
        vm.duplicate(original, in: context)

        let all = try context.fetch(FetchDescriptor<ThuleProduct>())
        #expect(all.count == 2)

        let copy = all.first { $0.id != original.id }!
        #expect(copy.keyCode == "N125")
        #expect(copy.productType == .roofBox)
        #expect(copy.numberOfLocks == 2)
        #expect(copy.id != original.id)
    }
}
