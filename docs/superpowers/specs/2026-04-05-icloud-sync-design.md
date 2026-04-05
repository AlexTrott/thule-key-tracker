# iCloud Sync via SwiftData + CloudKit

## Summary

Enable automatic cross-device iCloud sync for ThuleProduct data using SwiftData's built-in CloudKit integration. Offline-first — changes persist locally and sync in the background when connectivity is available. No sync UI. No migration away from SwiftData.

## Approach

**SwiftData + CloudKit (`.automatic`)** — the simplest path. SwiftData's `ModelContainer` accepts a `cloudKitDatabase` parameter that enables transparent CloudKit sync with zero changes to views, view models, or queries.

- Conflict resolution: last-writer-wins (CloudKit default). Appropriate for a single-user, multi-device app.
- Offline: fully automatic. Local SQLite persistence + background CloudKit sync.
- No sync status UI — invisible to the user.

## Data Model Changes

CloudKit requires all synced properties to have default values at the property declaration level (not just in `init`). Update `ThuleProduct`:

```swift
@Model
final class ThuleProduct {
    var id: UUID = UUID()
    var productType: ProductType = .other
    var customProductName: String?
    var keyCode: String = ""
    var nickname: String?
    var notes: String?
    var numberOfLocks: Int = 1
    var createdAt: Date = .now
    var updatedAt: Date = .now
}
```

No properties become optional. The `init` remains unchanged. Existing local data continues to work — SwiftData handles the schema migration automatically.

## App Configuration Changes

`ThuleKeyTrackerApp.swift` — replace the implicit model container with an explicit CloudKit-enabled one:

```swift
let config = ModelConfiguration(
    "ThuleKeyTracker",
    cloudKitDatabase: .automatic
)
let container = try ModelContainer(
    for: ThuleProduct.self,
    configurations: config
)
```

## Entitlements

The app requires two entitlements (added via Xcode Signing & Capabilities):

1. **iCloud** — CloudKit enabled, container: `iCloud.com.alextrott.ThuleKeyTracker`
2. **Background Modes** — Remote notifications (CloudKit uses silent push to trigger sync)

Entitlements file: `ThuleKeyTracker/ThuleKeyTracker.entitlements`

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.alextrott.ThuleKeyTracker</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Preview & Test Isolation

Preview and test containers must remain in-memory with no CloudKit:

```swift
ModelConfiguration(isStoredInMemoryOnly: true)
```

No changes needed — existing preview/test code already uses `isStoredInMemoryOnly: true`.

## Manual Steps (Completed)

1. Created CloudKit container `iCloud.com.alextrott.ThuleKeyTracker` in Apple Developer Portal
2. Added iCloud capability with CloudKit in Xcode Signing & Capabilities
3. Added Background Modes capability with Remote Notifications in Xcode

## Files Changed

| File | Change |
|------|--------|
| `ThuleProduct.swift` | Add default values to all non-optional properties |
| `ThuleKeyTrackerApp.swift` | Explicit `ModelConfiguration` with `cloudKitDatabase: .automatic` |

## What Does NOT Change

- All views, view models, and `@Query` usage — unchanged
- `ExportImport.swift` — unchanged
- `KeyCodeFormatter.swift` — unchanged
- Preview and test code — unchanged (already uses in-memory containers)
- No new dependencies — SwiftData's CloudKit support is built-in
