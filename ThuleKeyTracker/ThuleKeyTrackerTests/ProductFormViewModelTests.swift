import Foundation
import SwiftData
import Testing
@testable import ThuleKeyTracker

@Suite(.serialized)
struct ProductFormViewModelTests {

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

    // MARK: - New Product

    @Test @MainActor func newFormHasDefaults() {
        let vm = ProductFormViewModel()
        #expect(vm.productType == .roofBox)
        #expect(vm.keyCodeInput.isEmpty)
        #expect(vm.nickname.isEmpty)
        #expect(vm.notes.isEmpty)
        #expect(vm.numberOfLocks == 1)
        #expect(!vm.isEditing)
    }

    // MARK: - Key Code Validation

    @Test @MainActor func formattedKeyCodeUpdatesLive() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "125"
        #expect(vm.formattedKeyCode == "N125")
    }

    @Test @MainActor func formattedKeyCodeShowsPlaceholderForInvalid() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = ""
        #expect(vm.formattedKeyCode == "---")
    }

    @Test @MainActor func showsRangeWarningForOutOfRange() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "999"
        #expect(vm.showRangeWarning)
    }

    @Test @MainActor func noRangeWarningForStandardCode() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "125"
        #expect(!vm.showRangeWarning)
    }

    @Test @MainActor func canSaveRequiresValidKeyCode() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = ""
        #expect(!vm.canSave)
        vm.keyCodeInput = "125"
        #expect(vm.canSave)
    }

    // MARK: - Save New

    @Test @MainActor func saveCreatesProduct() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let vm = ProductFormViewModel()
        vm.productType = .roofBox
        vm.keyCodeInput = "125"
        vm.nickname = "My Box"

        vm.save(in: context)

        let products = try context.fetch(FetchDescriptor<ThuleProduct>())
        #expect(products.count == 1)
        #expect(products.first?.keyCode == "N125")
        #expect(products.first?.nickname == "My Box")
        #expect(products.first?.productType == .roofBox)
    }

    @Test @MainActor func saveTrimsEmptyStringsToNil() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "42"
        vm.nickname = "   "
        vm.notes = ""

        vm.save(in: context)

        let products = try context.fetch(FetchDescriptor<ThuleProduct>())
        #expect(products.first?.nickname == nil)
        #expect(products.first?.notes == nil)
    }

    // MARK: - Edit Existing

    @Test @MainActor func editFormPopulatesFromProduct() {
        let product = ThuleProduct(
            productType: .skiCarrier,
            keyCode: "N042",
            nickname: "Ski Rack",
            notes: "On the Volvo",
            numberOfLocks: 2
        )
        let vm = ProductFormViewModel(editing: product)

        #expect(vm.isEditing)
        #expect(vm.productType == .skiCarrier)
        #expect(vm.keyCodeInput == "042")
        #expect(vm.nickname == "Ski Rack")
        #expect(vm.notes == "On the Volvo")
        #expect(vm.numberOfLocks == 2)
    }

    @Test @MainActor func saveUpdatesExistingProduct() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let product = ThuleProduct(
            productType: .roofBox,
            keyCode: "N125",
            nickname: "Old Name"
        )
        context.insert(product)

        let vm = ProductFormViewModel(editing: product)
        vm.nickname = "New Name"
        vm.keyCodeInput = "200"
        vm.save(in: context)

        #expect(product.nickname == "New Name")
        #expect(product.keyCode == "N200")
    }

    // MARK: - Custom Product Name

    @Test @MainActor func customProductNameRequiredForOther() {
        let vm = ProductFormViewModel()
        vm.productType = .other
        #expect(vm.showCustomProductName)

        vm.productType = .roofBox
        #expect(!vm.showCustomProductName)
    }
}
