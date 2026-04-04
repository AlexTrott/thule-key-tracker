# Thule Key Tracker v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete offline iOS app for tracking Thule lock key numbers across multiple accessories.

**Architecture:** Single-module SwiftUI + SwiftData app using MVVM with `@Observable` view models. Views are dumb — they read state from view models and call methods. SwiftData `@Model` is the single source of truth. No singletons; `ModelContext` is passed via environment.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, Observation framework, iOS 17+, zero dependencies.

---

## File Map

```
ThuleKeyTracker/ThuleKeyTracker/
├── App/
│   └── ThuleKeyTrackerApp.swift          # App entry + SwiftData container setup
├── Models/
│   ├── ProductType.swift                 # Enum: product categories + display names + SF Symbols
│   └── ThuleProduct.swift                # SwiftData @Model
├── ViewModels/
│   ├── ProductListViewModel.swift        # List state: search, sort, grouping, CRUD actions
│   └── ProductFormViewModel.swift        # Form state: field values, validation, save
├── Views/
│   ├── ProductListView.swift             # Main list screen with search + segmented control
│   ├── ProductRowView.swift              # Single row: icon + title + key code badge
│   ├── KeyGroupedListView.swift          # Products grouped by key code
│   ├── ProductFormView.swift             # Add/edit sheet with live key code preview
│   ├── ProductDetailView.swift           # Read-only detail, edit button opens form
│   ├── SettingsView.swift                # App info, export/import, reset
│   ├── EmptyStateView.swift              # "No products yet" placeholder
│   └── Components/
│       ├── KeyCodeBadge.swift            # Large monospaced key code display
│       └── ProductTypeIcon.swift         # SF Symbol icon for a product type
├── Utilities/
│   ├── KeyCodeFormatter.swift            # Parse, normalise, validate key codes
│   └── ExportImport.swift               # JSON backup/restore
├── Preview Content/
│   └── PreviewSampleData.swift           # In-memory container + sample ThuleProducts
└── Resources/
    └── Assets.xcassets/
        └── AccentColor.colorset/         # Thule blue #005BA1
```

Tests:
```
ThuleKeyTracker/ThuleKeyTrackerTests/
├── KeyCodeFormatterTests.swift
├── ProductListViewModelTests.swift
├── ProductFormViewModelTests.swift
└── ExportImportTests.swift
```

---

## Task 1: Project Configuration

**Files:**
- Modify: `ThuleKeyTracker/ThuleKeyTracker.xcodeproj/project.pbxproj` (deployment target)
- Modify: `ThuleKeyTracker/ThuleKeyTracker/Assets.xcassets/AccentColor.colorset/Contents.json`

- [ ] **Step 1: Set accent colour to Thule blue (#005BA1)**

Replace `ThuleKeyTracker/ThuleKeyTracker/Assets.xcassets/AccentColor.colorset/Contents.json` with:

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.631",
          "green" : "0.353",
          "red" : "0.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] **Step 2: Create directory structure**

```bash
cd ThuleKeyTracker/ThuleKeyTracker
mkdir -p App Models ViewModels Views/Components Utilities "Preview Content"
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: configure accent colour and create directory structure"
```

---

## Task 2: ProductType Enum

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Models/ProductType.swift`

- [ ] **Step 1: Create ProductType enum**

```swift
import SwiftUI

enum ProductType: String, Codable, CaseIterable, Identifiable, Sendable {
    case roofBox
    case bikeRackTowbar
    case bikeRackRoof
    case bikeRackTailgate
    case roofBars
    case skiCarrier
    case kayakCarrier
    case cargoCarrier
    case cargoBag
    case trailerLock
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roofBox: String(localized: "Roof Box")
        case .bikeRackTowbar: String(localized: "Bike Rack (Towbar)")
        case .bikeRackRoof: String(localized: "Bike Rack (Roof)")
        case .bikeRackTailgate: String(localized: "Bike Rack (Tailgate)")
        case .roofBars: String(localized: "Roof Bars")
        case .skiCarrier: String(localized: "Ski Carrier")
        case .kayakCarrier: String(localized: "Kayak Carrier")
        case .cargoCarrier: String(localized: "Cargo Carrier")
        case .cargoBag: String(localized: "Cargo Bag")
        case .trailerLock: String(localized: "Trailer Lock")
        case .other: String(localized: "Other")
        }
    }

    var sfSymbol: String {
        switch self {
        case .roofBox: "shippingbox.fill"
        case .bikeRackTowbar: "bicycle"
        case .bikeRackRoof: "bicycle"
        case .bikeRackTailgate: "bicycle"
        case .roofBars: "rectangle.split.1x2"
        case .skiCarrier: "snowflake"
        case .kayakCarrier: "figure.rowing"
        case .cargoCarrier: "cart.fill"
        case .cargoBag: "bag.fill"
        case .trailerLock: "lock.fill"
        case .other: "wrench.and.screwdriver.fill"
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Models/ProductType.swift
git commit -m "feat: add ProductType enum with display names and SF Symbols"
```

---

## Task 3: KeyCodeFormatter (TDD)

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Utilities/KeyCodeFormatter.swift`
- Create: `ThuleKeyTracker/ThuleKeyTrackerTests/KeyCodeFormatterTests.swift`

- [ ] **Step 1: Write failing tests for normalisation**

Replace `ThuleKeyTracker/ThuleKeyTrackerTests/ThuleKeyTrackerTests.swift` with an empty file (or delete it — it's the Xcode boilerplate).

Create `ThuleKeyTracker/ThuleKeyTrackerTests/KeyCodeFormatterTests.swift`:

```swift
import Testing
@testable import ThuleKeyTracker

struct KeyCodeFormatterTests {

    // MARK: - Normalisation

    @Test func normalisesPlainNumber() {
        #expect(KeyCodeFormatter.normalise("125") == "N125")
    }

    @Test func normalisesPrefixedUppercase() {
        #expect(KeyCodeFormatter.normalise("N125") == "N125")
    }

    @Test func normalisesPrefixedLowercase() {
        #expect(KeyCodeFormatter.normalise("n125") == "N125")
    }

    @Test func normalisesWithSpace() {
        #expect(KeyCodeFormatter.normalise("N 125") == "N125")
    }

    @Test func normalisesPadsToThreeDigits() {
        #expect(KeyCodeFormatter.normalise("1") == "N001")
        #expect(KeyCodeFormatter.normalise("42") == "N042")
    }

    @Test func normalisesAlreadyPadded() {
        #expect(KeyCodeFormatter.normalise("N001") == "N001")
    }

    @Test func normalisesReturnsNilForEmpty() {
        #expect(KeyCodeFormatter.normalise("") == nil)
    }

    @Test func normalisesReturnsNilForNonNumeric() {
        #expect(KeyCodeFormatter.normalise("abc") == nil)
        #expect(KeyCodeFormatter.normalise("N") == nil)
        #expect(KeyCodeFormatter.normalise("NNN") == nil)
    }

    @Test func normalisesReturnsNilForZero() {
        #expect(KeyCodeFormatter.normalise("0") == nil)
        #expect(KeyCodeFormatter.normalise("000") == nil)
    }

    @Test func normalisesTrimsWhitespace() {
        #expect(KeyCodeFormatter.normalise("  125  ") == "N125")
        #expect(KeyCodeFormatter.normalise(" N 42 ") == "N042")
    }

    // MARK: - Validation

    @Test func isValidForValidCodes() {
        #expect(KeyCodeFormatter.isValid("N125"))
        #expect(KeyCodeFormatter.isValid("125"))
        #expect(KeyCodeFormatter.isValid("n001"))
    }

    @Test func isValidForInvalidCodes() {
        #expect(!KeyCodeFormatter.isValid(""))
        #expect(!KeyCodeFormatter.isValid("abc"))
        #expect(!KeyCodeFormatter.isValid("0"))
    }

    // MARK: - Standard Range

    @Test func isInStandardRange() {
        #expect(KeyCodeFormatter.isInStandardRange("N001"))
        #expect(KeyCodeFormatter.isInStandardRange("N125"))
        #expect(KeyCodeFormatter.isInStandardRange("N250"))
    }

    @Test func isOutsideStandardRange() {
        #expect(!KeyCodeFormatter.isInStandardRange("N000"))
        #expect(!KeyCodeFormatter.isInStandardRange("N251"))
        #expect(!KeyCodeFormatter.isInStandardRange("N999"))
    }

    @Test func isInStandardRangeHandlesUnnormalisedInput() {
        #expect(KeyCodeFormatter.isInStandardRange("125"))
        #expect(!KeyCodeFormatter.isInStandardRange("999"))
    }

    // MARK: - Display Formatting

    @Test func displayFormatting() {
        #expect(KeyCodeFormatter.displayString(for: "125") == "N125")
        #expect(KeyCodeFormatter.displayString(for: "invalid") == "---")
    }
}
```

- [ ] **Step 2: Run tests — expect failure (type not found)**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests 2>&1 | tail -20
```

Expected: Build failure — `KeyCodeFormatter` not defined.

- [ ] **Step 3: Implement KeyCodeFormatter**

Create `ThuleKeyTracker/ThuleKeyTracker/Utilities/KeyCodeFormatter.swift`:

```swift
import Foundation

enum KeyCodeFormatter: Sendable {

    static func normalise(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let stripped = trimmed
            .replacingOccurrences(of: " ", with: "")
            .uppercased()

        let digits: String
        if stripped.hasPrefix("N") {
            digits = String(stripped.dropFirst())
        } else {
            digits = stripped
        }

        guard !digits.isEmpty,
              digits.allSatisfy(\.isNumber),
              let number = Int(digits),
              number > 0 else {
            return nil
        }

        return "N\(String(format: "%03d", number))"
    }

    static func isValid(_ input: String) -> Bool {
        normalise(input) != nil
    }

    static func isInStandardRange(_ input: String) -> Bool {
        guard let normalised = normalise(input),
              let number = Int(normalised.dropFirst()) else {
            return false
        }
        return (1...250).contains(number)
    }

    static func displayString(for input: String) -> String {
        normalise(input) ?? "---"
    }
}
```

- [ ] **Step 4: Run tests — expect all pass**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Utilities/KeyCodeFormatter.swift ThuleKeyTracker/ThuleKeyTrackerTests/KeyCodeFormatterTests.swift
git commit -m "feat: add KeyCodeFormatter with full test coverage"
```

---

## Task 4: ThuleProduct SwiftData Model

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Models/ThuleProduct.swift`

- [ ] **Step 1: Create the SwiftData model**

```swift
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
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Models/ThuleProduct.swift
git commit -m "feat: add ThuleProduct SwiftData model"
```

---

## Task 5: Preview Sample Data

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Preview Content/PreviewSampleData.swift`

- [ ] **Step 1: Create shared preview helpers**

```swift
import SwiftData

@MainActor
enum PreviewSampleData {

    static var sampleProducts: [ThuleProduct] {
        [
            ThuleProduct(
                productType: .roofBox,
                keyCode: "N125",
                nickname: "Motion XT XL",
                notes: "Spare key in kitchen drawer",
                numberOfLocks: 2
            ),
            ThuleProduct(
                productType: .bikeRackTowbar,
                keyCode: "N125",
                nickname: "EasyFold XT 2",
                numberOfLocks: 1
            ),
            ThuleProduct(
                productType: .roofBars,
                keyCode: "N042",
                nickname: "WingBar Evo",
                numberOfLocks: 4
            ),
            ThuleProduct(
                productType: .skiCarrier,
                keyCode: "N042",
                numberOfLocks: 1
            ),
            ThuleProduct(
                productType: .kayakCarrier,
                keyCode: "N200",
                nickname: "Hull-a-Port XT",
                numberOfLocks: 2
            ),
        ]
    }

    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ThuleProduct.self,
            configurations: config
        )
        for product in sampleProducts {
            container.mainContext.insert(product)
        }
        return container
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add "ThuleKeyTracker/ThuleKeyTracker/Preview Content/PreviewSampleData.swift"
git commit -m "feat: add preview sample data with in-memory SwiftData container"
```

---

## Task 6: App Entry Point

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/App/ThuleKeyTrackerApp.swift`
- Delete: `ThuleKeyTracker/ThuleKeyTracker/ThuleKeyTrackerApp.swift`
- Delete: `ThuleKeyTracker/ThuleKeyTracker/ContentView.swift`

- [ ] **Step 1: Create the app entry point with SwiftData container**

Create `ThuleKeyTracker/ThuleKeyTracker/App/ThuleKeyTrackerApp.swift`:

```swift
import SwiftData
import SwiftUI

@main
struct ThuleKeyTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ProductListView()
        }
        .modelContainer(for: ThuleProduct.self)
    }
}
```

- [ ] **Step 2: Delete old boilerplate files**

```bash
rm ThuleKeyTracker/ThuleKeyTracker/ThuleKeyTrackerApp.swift
rm ThuleKeyTracker/ThuleKeyTracker/ContentView.swift
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: configure app entry point with SwiftData container"
```

Note: The project will not compile yet — `ProductListView` doesn't exist. That's fine; it's created in Task 12.

---

## Task 7: UI Components

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/Components/KeyCodeBadge.swift`
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/Components/ProductTypeIcon.swift`

- [ ] **Step 1: Create KeyCodeBadge**

```swift
import SwiftUI

struct KeyCodeBadge: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.title.monospaced().bold())
            .foregroundStyle(.primary)
    }
}

#Preview {
    KeyCodeBadge(code: "N125")
}
```

- [ ] **Step 2: Create ProductTypeIcon**

```swift
import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: productType.sfSymbol)
            .font(.system(size: size))
            .foregroundStyle(.accent)
            .frame(width: size + 8, height: size + 8)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(ProductType.allCases) { type in
            HStack {
                ProductTypeIcon(productType: type)
                Text(type.displayName)
            }
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/Components/
git commit -m "feat: add KeyCodeBadge and ProductTypeIcon components"
```

---

## Task 8: EmptyStateView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/EmptyStateView.swift`

- [ ] **Step 1: Create the empty state**

```swift
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            String(localized: "No Thule Products Yet"),
            systemImage: "key.fill",
            description: Text("Tap + to add your first product and its key code.")
        )
    }
}

#Preview {
    EmptyStateView()
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/EmptyStateView.swift
git commit -m "feat: add empty state view"
```

---

## Task 9: ProductFormViewModel (TDD)

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductFormViewModel.swift`
- Create: `ThuleKeyTracker/ThuleKeyTrackerTests/ProductFormViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

Create `ThuleKeyTracker/ThuleKeyTrackerTests/ProductFormViewModelTests.swift`:

```swift
import SwiftData
import Testing
@testable import ThuleKeyTracker

@MainActor
struct ProductFormViewModelTests {

    private func makeContext() -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ThuleProduct.self,
            configurations: config
        )
        return container.mainContext
    }

    // MARK: - New Product

    @Test func newFormHasDefaults() {
        let vm = ProductFormViewModel()
        #expect(vm.productType == .roofBox)
        #expect(vm.keyCodeInput.isEmpty)
        #expect(vm.nickname.isEmpty)
        #expect(vm.notes.isEmpty)
        #expect(vm.numberOfLocks == 1)
        #expect(!vm.isEditing)
    }

    // MARK: - Key Code Validation

    @Test func formattedKeyCodeUpdatesLive() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "125"
        #expect(vm.formattedKeyCode == "N125")
    }

    @Test func formattedKeyCodeShowsPlaceholderForInvalid() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = ""
        #expect(vm.formattedKeyCode == "---")
    }

    @Test func showsRangeWarningForOutOfRange() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "999"
        #expect(vm.showRangeWarning)
    }

    @Test func noRangeWarningForStandardCode() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = "125"
        #expect(!vm.showRangeWarning)
    }

    @Test func canSaveRequiresValidKeyCode() {
        let vm = ProductFormViewModel()
        vm.keyCodeInput = ""
        #expect(!vm.canSave)
        vm.keyCodeInput = "125"
        #expect(vm.canSave)
    }

    // MARK: - Save New

    @Test func saveCreatesProduct() throws {
        let context = makeContext()
        let vm = ProductFormViewModel()
        vm.productType = .roofBox
        vm.keyCodeInput = "125"
        vm.nickname = "My Box"

        vm.save(in: context)

        let descriptor = FetchDescriptor<ThuleProduct>()
        let products = try context.fetch(descriptor)
        #expect(products.count == 1)
        #expect(products.first?.keyCode == "N125")
        #expect(products.first?.nickname == "My Box")
        #expect(products.first?.productType == .roofBox)
    }

    @Test func saveTrimsEmptyStringsToNil() throws {
        let context = makeContext()
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

    @Test func editFormPopulatesFromProduct() {
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
        #expect(vm.keyCodeInput == "N042")
        #expect(vm.nickname == "Ski Rack")
        #expect(vm.notes == "On the Volvo")
        #expect(vm.numberOfLocks == 2)
    }

    @Test func saveUpdatesExistingProduct() throws {
        let context = makeContext()
        let product = ThuleProduct(
            productType: .roofBox,
            keyCode: "N125",
            nickname: "Old Name"
        )
        context.insert(product)

        let vm = ProductFormViewModel(editing: product)
        vm.nickname = "New Name"
        vm.keyCodeInput = "N200"
        vm.save(in: context)

        #expect(product.nickname == "New Name")
        #expect(product.keyCode == "N200")
    }

    // MARK: - Custom Product Name

    @Test func customProductNameRequiredForOther() {
        let vm = ProductFormViewModel()
        vm.productType = .other
        #expect(vm.showCustomProductName)

        vm.productType = .roofBox
        #expect(!vm.showCustomProductName)
    }
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ProductFormViewModelTests 2>&1 | tail -20
```

Expected: Build failure — `ProductFormViewModel` not defined.

- [ ] **Step 3: Implement ProductFormViewModel**

Create `ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductFormViewModel.swift`:

```swift
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
        self.keyCodeInput = product.keyCode
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
```

- [ ] **Step 4: Run tests — expect all pass**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ProductFormViewModelTests 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductFormViewModel.swift ThuleKeyTracker/ThuleKeyTrackerTests/ProductFormViewModelTests.swift
git commit -m "feat: add ProductFormViewModel with validation and save logic"
```

---

## Task 10: ProductListViewModel (TDD)

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductListViewModel.swift`
- Create: `ThuleKeyTracker/ThuleKeyTrackerTests/ProductListViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

Create `ThuleKeyTracker/ThuleKeyTrackerTests/ProductListViewModelTests.swift`:

```swift
import SwiftData
import Testing
@testable import ThuleKeyTracker

@MainActor
struct ProductListViewModelTests {

    private func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: ThuleProduct.self, configurations: config)
    }

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

    @Test func searchFiltersByKeyCode() throws {
        let container = makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "125"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.keyCode == "N125" })
    }

    @Test func searchFiltersByNickname() throws {
        let container = makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "wing"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 1)
        #expect(filtered.first?.nickname == "WingBar")
    }

    @Test func searchFiltersByProductType() throws {
        let container = makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = "ski"
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 1)
        #expect(filtered.first?.productType == .skiCarrier)
    }

    @Test func emptySearchReturnsAll() throws {
        let container = makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        vm.searchText = ""
        let filtered = vm.filteredProducts(from: all)
        #expect(filtered.count == 4)
    }

    // MARK: - Grouping

    @Test func groupsByKeyCode() throws {
        let container = makeContainer()
        populate(container.mainContext)
        let vm = ProductListViewModel()

        let all = try container.mainContext.fetch(FetchDescriptor<ThuleProduct>())
        let grouped = vm.groupedByKeyCode(from: all)

        #expect(grouped.count == 3)
        let n125Group = grouped.first { $0.keyCode == "N125" }
        #expect(n125Group?.products.count == 2)
    }

    // MARK: - Duplicate

    @Test func duplicateCreatesNewProduct() throws {
        let container = makeContainer()
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
```

- [ ] **Step 2: Run tests — expect failure**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ProductListViewModelTests 2>&1 | tail -20
```

Expected: Build failure — `ProductListViewModel` not defined.

- [ ] **Step 3: Implement ProductListViewModel**

Create `ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductListViewModel.swift`:

```swift
import Observation
import SwiftData

enum ListMode: String, CaseIterable {
    case byProduct = "By Product"
    case byKey = "By Key"
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
```

- [ ] **Step 4: Run tests — expect all pass**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ProductListViewModelTests 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/ViewModels/ProductListViewModel.swift ThuleKeyTracker/ThuleKeyTrackerTests/ProductListViewModelTests.swift
git commit -m "feat: add ProductListViewModel with search, grouping, and duplicate"
```

---

## Task 11: ProductRowView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/ProductRowView.swift`

- [ ] **Step 1: Create the row view**

```swift
import SwiftUI

struct ProductRowView: View {
    let product: ThuleProduct

    var body: some View {
        HStack(spacing: 12) {
            ProductTypeIcon(productType: product.productType)

            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(.headline)
                if let nickname = product.nickname, product.productType != .other || product.customProductName != nil {
                    Text(product.productType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            KeyCodeBadge(code: product.keyCode)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ForEach(PreviewSampleData.sampleProducts) { product in
            ProductRowView(product: product)
        }
    }
    .modelContainer(PreviewSampleData.container)
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/ProductRowView.swift
git commit -m "feat: add ProductRowView with icon, name, and key code badge"
```

---

## Task 12: ProductFormView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/ProductFormView.swift`

- [ ] **Step 1: Create the add/edit form**

```swift
import SwiftUI

struct ProductFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProductFormViewModel

    init(editing product: ThuleProduct? = nil) {
        _viewModel = State(initialValue: product.map {
            ProductFormViewModel(editing: $0)
        } ?? ProductFormViewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                keyCodeSection
                productSection
                detailsSection
            }
            .navigationTitle(viewModel.isEditing
                ? String(localized: "Edit Product")
                : String(localized: "Add Product"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        viewModel.save(in: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    private var keyCodeSection: some View {
        Section {
            VStack(spacing: 12) {
                Text(viewModel.formattedKeyCode)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.canSave ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                TextField(String(localized: "Key code (e.g. 125 or N125)"), text: $viewModel.keyCodeInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                if viewModel.showRangeWarning {
                    Label(
                        String(localized: "Outside standard Thule range (N001\u{2013}N250)"),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Key Code")
        }
    }

    private var productSection: some View {
        Section {
            Picker(String(localized: "Product Type"), selection: $viewModel.productType) {
                ForEach(ProductType.allCases) { type in
                    Label(type.displayName, systemImage: type.sfSymbol)
                        .tag(type)
                }
            }

            if viewModel.showCustomProductName {
                TextField(String(localized: "Product name"), text: $viewModel.customProductName)
            }
        } header: {
            Text("Product")
        }
    }

    private var detailsSection: some View {
        Section {
            TextField(String(localized: "Nickname (optional)"), text: $viewModel.nickname)

            Stepper(
                String(localized: "Locks: \(viewModel.numberOfLocks)"),
                value: $viewModel.numberOfLocks,
                in: 1...20
            )

            TextField(String(localized: "Notes (optional)"), text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Details")
        }
    }
}

#Preview("Add") {
    ProductFormView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Edit") {
    ProductFormView(editing: PreviewSampleData.sampleProducts.first!)
        .modelContainer(PreviewSampleData.container)
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/ProductFormView.swift
git commit -m "feat: add ProductFormView with live key code preview and validation"
```

---

## Task 13: ProductDetailView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/ProductDetailView.swift`

- [ ] **Step 1: Create the detail view**

```swift
import SwiftUI

struct ProductDetailView: View {
    let product: ThuleProduct
    @State private var showingEditForm = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text(product.keyCode)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                    Text(product.displayName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }

            Section {
                Label(product.productType.displayName, systemImage: product.productType.sfSymbol)
                if let custom = product.customProductName, product.productType == .other {
                    LabeledContent(String(localized: "Custom Name"), value: custom)
                }
                if let nickname = product.nickname {
                    LabeledContent(String(localized: "Nickname"), value: nickname)
                }
                LabeledContent(String(localized: "Number of Locks"), value: "\(product.numberOfLocks)")
            } header: {
                Text("Product Info")
            }

            if let notes = product.notes, !notes.isEmpty {
                Section {
                    Text(notes)
                } header: {
                    Text("Notes")
                }
            }

            Section {
                LabeledContent(String(localized: "Added"), value: product.createdAt.formatted(date: .abbreviated, time: .omitted))
                LabeledContent(String(localized: "Updated"), value: product.updatedAt.formatted(date: .abbreviated, time: .omitted))
            } header: {
                Text("Dates")
            }
        }
        .navigationTitle(product.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(String(localized: "Edit")) {
                showingEditForm = true
            }
        }
        .sheet(isPresented: $showingEditForm) {
            ProductFormView(editing: product)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: PreviewSampleData.sampleProducts.first!)
    }
    .modelContainer(PreviewSampleData.container)
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/ProductDetailView.swift
git commit -m "feat: add ProductDetailView with key code hero and edit sheet"
```

---

## Task 14: KeyGroupedListView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/KeyGroupedListView.swift`

- [ ] **Step 1: Create the grouped list view**

```swift
import SwiftUI

struct KeyGroupedListView: View {
    let groups: [KeyGroup]

    var body: some View {
        ForEach(groups) { group in
            Section {
                ForEach(group.products) { product in
                    NavigationLink(value: product.id) {
                        HStack(spacing: 12) {
                            ProductTypeIcon(productType: product.productType, size: 22)
                            Text(product.displayName)
                        }
                    }
                }
            } header: {
                Text(group.keyCode)
                    .font(.headline.monospaced())
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
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/KeyGroupedListView.swift
git commit -m "feat: add KeyGroupedListView for group-by-key-code display"
```

---

## Task 15: ProductListView (Main Screen)

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/ProductListView.swift`

- [ ] **Step 1: Create the main list view**

```swift
import SwiftData
import SwiftUI

struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThuleProduct.createdAt, order: .reverse) private var products: [ThuleProduct]
    @State private var viewModel = ProductListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if products.isEmpty {
                    EmptyStateView()
                } else {
                    listContent
                }
            }
            .navigationTitle(String(localized: "Thule Keys"))
            .searchable(text: $viewModel.searchText, prompt: String(localized: "Search by key code, name, or type"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddForm) {
                ProductFormView()
            }
            .navigationDestination(for: UUID.self) { productID in
                if let product = products.first(where: { $0.id == productID }) {
                    ProductDetailView(product: product)
                }
            }
        }
    }

    private var listContent: some View {
        List {
            Picker(String(localized: "View"), selection: $viewModel.listMode) {
                ForEach(ListMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.bottom, 4)

            switch viewModel.listMode {
            case .byProduct:
                byProductSection
            case .byKey:
                KeyGroupedListView(groups: viewModel.groupedByKeyCode(from: products))
            }
        }
    }

    private var byProductSection: some View {
        ForEach(viewModel.filteredProducts(from: products)) { product in
            NavigationLink(value: product.id) {
                ProductRowView(product: product)
            }
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
```

- [ ] **Step 2: Build the project**

```bash
xcodebuild build -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

Expected: Build succeeds. The app's core loop (add, view, search, edit, delete) is now functional.

- [ ] **Step 3: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/ProductListView.swift
git commit -m "feat: add ProductListView — main screen with search, grouping, swipe actions"
```

---

## Task 16: ExportImport Utility (TDD)

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Utilities/ExportImport.swift`
- Create: `ThuleKeyTracker/ThuleKeyTrackerTests/ExportImportTests.swift`

- [ ] **Step 1: Write failing tests**

Create `ThuleKeyTracker/ThuleKeyTrackerTests/ExportImportTests.swift`:

```swift
import Foundation
import SwiftData
import Testing
@testable import ThuleKeyTracker

@MainActor
struct ExportImportTests {

    private func makeContext() -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ThuleProduct.self,
            configurations: config
        )
        return container.mainContext
    }

    @Test func exportProducesValidJSON() throws {
        let context = makeContext()
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

    @Test func importRoundTrips() throws {
        let context = makeContext()
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
        #expect(imported.first?.id != original.id) // new UUID on import
    }

    @Test func importRejectsInvalidJSON() {
        let garbage = Data("not json".utf8)
        #expect(throws: (any Error).self) {
            try ExportImport.importJSON(from: garbage)
        }
    }
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ExportImportTests 2>&1 | tail -20
```

Expected: Build failure — `ExportImport` not defined.

- [ ] **Step 3: Implement ExportImport**

Create `ThuleKeyTracker/ThuleKeyTracker/Utilities/ExportImport.swift`:

```swift
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
```

- [ ] **Step 4: Run tests — expect all pass**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests/ExportImportTests 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Utilities/ExportImport.swift ThuleKeyTracker/ThuleKeyTrackerTests/ExportImportTests.swift
git commit -m "feat: add JSON export/import utility with round-trip tests"
```

---

## Task 17: SettingsView

**Files:**
- Create: `ThuleKeyTracker/ThuleKeyTracker/Views/SettingsView.swift`

- [ ] **Step 1: Create settings view**

```swift
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [ThuleProduct]
    @State private var showingResetConfirmation = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importError: String?
    @State private var showingImportError = false

    var body: some View {
        Form {
            Section {
                LabeledContent(String(localized: "Products"), value: "\(products.count)")
                let uniqueKeys = Set(products.map(\.keyCode)).count
                LabeledContent(String(localized: "Unique Keys"), value: "\(uniqueKeys)")
            } header: {
                Text("Summary")
            }

            Section {
                Button(String(localized: "Export Data")) {
                    showingExporter = true
                }
                Button(String(localized: "Import Data")) {
                    showingImporter = true
                }
            } header: {
                Text("Backup")
            }

            Section {
                Button(String(localized: "Delete All Data"), role: .destructive) {
                    showingResetConfirmation = true
                }
            } header: {
                Text("Reset")
            }

            Section {
                LabeledContent(String(localized: "Version"), value: appVersion)
            } header: {
                Text("About")
            } footer: {
                Text("Thule key codes follow the pattern N001\u{2013}N250. This app is not affiliated with Thule Group.")
            }
        }
        .navigationTitle(String(localized: "Settings"))
        .confirmationDialog(
            String(localized: "Delete All Data?"),
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete Everything"), role: .destructive) {
                deleteAllProducts()
            }
        } message: {
            Text("This will permanently remove all your saved products. This cannot be undone.")
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: JSONExportDocument(products: products),
            contentType: .json,
            defaultFilename: "thule-keys-backup"
        ) { _ in }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result)
        }
        .alert(
            String(localized: "Import Failed"),
            isPresented: $showingImportError
        ) {
            Button(String(localized: "OK")) {}
        } message: {
            Text(importError ?? "")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func deleteAllProducts() {
        for product in products {
            modelContext.delete(product)
        }
    }

    private func handleImport(_ result: Result<URL, any Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                let imported = try ExportImport.importJSON(from: data)
                for product in imported {
                    modelContext.insert(product)
                }
            } catch {
                importError = error.localizedDescription
                showingImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showingImportError = true
        }
    }
}

import UniformTypeIdentifiers

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(products: [ThuleProduct]) {
        self.data = (try? ExportImport.exportJSON(from: products)) ?? Data()
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewSampleData.container)
}
```

- [ ] **Step 2: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/SettingsView.swift
git commit -m "feat: add SettingsView with export, import, and reset"
```

---

## Task 18: Wire Settings into ProductListView

**Files:**
- Modify: `ThuleKeyTracker/ThuleKeyTracker/Views/ProductListView.swift`

- [ ] **Step 1: Add settings navigation to the toolbar**

In `ProductListView`, add to the toolbar:

```swift
ToolbarItem(placement: .topBarLeading) {
    NavigationLink {
        SettingsView()
    } label: {
        Image(systemName: "gearshape")
    }
}
```

- [ ] **Step 2: Build and verify**

```bash
xcodebuild build -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add ThuleKeyTracker/ThuleKeyTracker/Views/ProductListView.swift
git commit -m "feat: wire settings into main navigation toolbar"
```

---

## Task 19: Delete Boilerplate Test File

**Files:**
- Delete: `ThuleKeyTracker/ThuleKeyTrackerTests/ThuleKeyTrackerTests.swift`

- [ ] **Step 1: Remove Xcode boilerplate test**

```bash
rm ThuleKeyTracker/ThuleKeyTrackerTests/ThuleKeyTrackerTests.swift
```

- [ ] **Step 2: Run full test suite**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing ThuleKeyTrackerTests 2>&1 | tail -30
```

Expected: All tests pass (KeyCodeFormatterTests, ProductFormViewModelTests, ProductListViewModelTests, ExportImportTests).

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove boilerplate test file, all tests passing"
```

---

## Task 20: Full Build Verification & Polish

- [ ] **Step 1: Clean build**

```bash
xcodebuild clean build -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

Expected: **BUILD SUCCEEDED** with zero warnings.

- [ ] **Step 2: Run all tests**

```bash
xcodebuild test -project ThuleKeyTracker/ThuleKeyTracker.xcodeproj -scheme ThuleKeyTracker -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 3: Verify file count and structure**

```bash
find ThuleKeyTracker/ThuleKeyTracker -name "*.swift" | sort
find ThuleKeyTracker/ThuleKeyTrackerTests -name "*.swift" | sort
```

Expected 16 Swift source files + 4 test files matching the file map at the top of this plan.

- [ ] **Step 4: Final commit if any changes**

```bash
git status
# If clean, nothing to do. If changes, commit as "chore: final polish"
```
