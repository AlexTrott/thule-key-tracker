# Thule Key Tracker — Claude Code Agent Instructions

## Project Overview

A lightweight iOS app for tracking Thule lock key numbers across multiple accessories (roof boxes, bike racks, ski carriers, etc.). Pure utility — offline-first, no account, no server.

## Tech Stack

- **Language:** Swift 6 (strict concurrency)
- **UI:** SwiftUI
- **Data:** SwiftData
- **Min target:** iOS 17.0
- **Architecture:** MVVM with `@Observable` view models
- **Dependencies:** None. Zero SPM packages. Everything is first-party Apple.
- **Xcode:** 16+

## Project Structure

```
ThuleKeyTracker/
├── App/
│   └── ThuleKeyTrackerApp.swift          # App entry point
├── Models/
│   ├── ThuleProduct.swift                # SwiftData @Model
│   └── ProductType.swift                 # Enum with display names + SF Symbols
├── ViewModels/
│   ├── ProductListViewModel.swift        # List, search, filtering, grouping
│   └── ProductFormViewModel.swift        # Add/edit form logic + validation
├── Views/
│   ├── ProductListView.swift             # Main list screen
│   ├── ProductRowView.swift              # Single row in the list
│   ├── KeyGroupedListView.swift          # Grouped-by-key-code view
│   ├── ProductFormView.swift             # Add/edit sheet
│   ├── ProductDetailView.swift           # Detail view (tap from list)
│   ├── SettingsView.swift                # Settings screen
│   ├── EmptyStateView.swift              # Empty state placeholder
│   └── Components/
│       ├── KeyCodeBadge.swift            # Large, prominent key code display
│       ├── ProductTypeIcon.swift         # SF Symbol icon for product type
│       └── SearchBar.swift               # Search bar (if not using .searchable)
├── Utilities/
│   ├── KeyCodeFormatter.swift            # Parse/format/validate key codes
│   └── ExportImport.swift               # JSON export/import for backup
├── Resources/
│   └── Assets.xcassets
└── Preview Content/
    └── PreviewSampleData.swift           # Sample products for SwiftUI previews
```

## Architecture Rules

1. **Views are dumb.** Views read state from view models and call methods on them. No business logic in views.
2. **View models are `@Observable`.** Use the Observation framework, not Combine. No `@Published`, no `ObservableObject`.
3. **SwiftData model is the source of truth.** The `@Model` class is the single canonical representation. No separate DTO layers.
4. **No singletons.** Pass the `ModelContext` via the environment. View models receive it via init.
5. **Previews must work.** Every view must have a `#Preview` block with sample data using an in-memory SwiftData container.

## Data Model

```swift
@Model
final class ThuleProduct {
    var id: UUID
    var productType: ProductType
    var customProductName: String?
    var keyCode: String              // Stored normalised, e.g. "N125"
    var nickname: String?
    var notes: String?
    var numberOfLocks: Int
    var createdAt: Date
    var updatedAt: Date
}
```

### ProductType Enum

```swift
enum ProductType: String, Codable, CaseIterable, Identifiable {
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
    var displayName: String { ... }
    var sfSymbol: String { ... }
}
```

## Key Code Rules

- Thule key codes follow the pattern `N` followed by 1-3 digits (e.g., `N001`, `N125`, `N250`).
- User input should be flexible: accept `125`, `N125`, `n125`, `N 125`.
- Always store and display in normalised form: `N` prefix, zero-padded to 3 digits → `N001`, `N042`, `N125`.
- The typical range is N001–N250, but do NOT hard-reject codes outside this range — just show a soft warning ("This is outside the standard Thule range").
- The `KeyCodeFormatter` utility handles all parsing, normalisation, and validation.

## Design Guidelines

- **Key code is king.** On every row and detail view, the key code should be the largest, most prominent text element. Use `.font(.title)` or larger, monospaced weight.
- **Dark mode first.** Design and test in dark mode primarily — users will often check this in dim lighting (car parks, garages).
- **iOS-native feel.** Use `NavigationStack`, `.searchable`, `Form`, `Section`, standard SwiftUI patterns. No custom navigation chrome.
- **SF Symbols for product types.** Map each `ProductType` to a sensible SF Symbol. Examples:
  - Roof box → `shippingbox.fill`
  - Bike rack → `bicycle`
  - Roof bars → `rectangle.split.1x2`
  - Ski carrier → `snowflake`
  - Kayak → `figure.rowing`
  - Other → `wrench.and.screwdriver.fill`
- **Accent colour:** Use a Thule-inspired blue (`#005BA1`) as the app's accent colour.

## Coding Conventions

- Use Swift 6 strict concurrency. Mark types `Sendable` where appropriate.
- Prefer `if let` / `guard let` over force unwraps. Zero force unwraps in production code.
- Use `@Environment(\.modelContext)` in views, pass to view models explicitly.
- String literals for user-facing text should be wrapped in `String(localized:)` for future localisation readiness.
- Keep files short. If a file exceeds ~150 lines, split it.
- Name test files `[Feature]Tests.swift` in a `ThuleKeyTrackerTests` target.

## SwiftData Previews Pattern

Every view that needs data should use this pattern for previews:

```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ThuleProduct.self, configurations: config)
    // Insert sample data into container.mainContext
    return ProductListView()
        .modelContainer(container)
}
```

Use `PreviewSampleData.swift` for shared sample product arrays.

## Testing

- Unit test `KeyCodeFormatter` thoroughly — it's the core logic.
- Unit test view model filtering/search/grouping logic.
- No UI tests in v1 — the app is too small to justify the overhead.

## What NOT to Build

- No networking layer. No API calls. No analytics.
- No onboarding flow. Empty state is the onboarding.
- No CloudKit sync (v2 consideration).
- No widgets (v2 consideration).
- No custom fonts. System fonts only.
