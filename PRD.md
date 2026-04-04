# Thule Key Tracker — Product Requirements Document

## Overview

A lightweight iOS app for tracking Thule lock key numbers across multiple accessories. Thule uses a universal key system where each lock cylinder has a specific key code (e.g., N001–N250). Owners of multiple Thule products — roof boxes, bike racks, ski carriers, roof bars — often lose track of which key code belongs to which product, especially when keys look identical.

**Thule Key Tracker** solves this by giving users a simple catalogue of their Thule gear, each linked to its key code, with the ability to quickly look up which key opens what.

---

## Problem Statement

Thule products share a common key system, but there's no easy way to remember which numbered key belongs to which accessory. Users resort to sticky notes, photos of key stamps, or trial-and-error — particularly frustrating when loading up for a trip with multiple locked accessories on the car.

**Target user:** Anyone who owns two or more Thule lockable products and has experienced the "which key is which?" moment in a car park.

---

## Goals

1. **Instant lookup** — Open the app, see all your Thule gear and the key code for each, in under 2 seconds.
2. **Zero-friction entry** — Adding a new product + key code should take under 15 seconds.
3. **Offline-first** — Works entirely without a network connection. Data stays on-device.
4. **Minimal footprint** — No account required, no server, no analytics. Pure utility.

---

## Core Features

### 1. Product List (Home Screen)

The primary view is a list of the user's Thule products, each displaying:

| Field | Description | Required |
|---|---|---|
| **Product type** | Picked from a predefined list (see below) | Yes |
| **Key code** | The Thule key number, e.g., `N125` | Yes |
| **Nickname** | Optional label, e.g., "Megan's bike rack" | No |
| **Notes** | Free-text, e.g., "Spare key in kitchen drawer" | No |
| **Number of locks** | How many lock cores on this product (default 1) | No |

Each row shows:
- An icon representing the product type
- The nickname or product type as the title
- The key code displayed prominently (large, monospaced)

Tapping a row opens the detail/edit view.

### 2. Predefined Product Types

Curated list with SF Symbol or custom icon per type:

- Roof box
- Bike rack (towbar)
- Bike rack (roof)
- Bike rack (tailgate/boot)
- Roof bars / crossbars
- Ski / snowboard carrier
- Kayak / canoe carrier
- Roof basket / cargo carrier
- Cargo bag (lockable)
- Trailer / caravan lock
- Other

Users select from this list when adding a product. "Other" includes a free-text product name field.

### 3. Add / Edit Product

A simple form with the fields from the table above. Key code entry should:

- Accept numeric input (e.g., `125`) and auto-format to Thule convention (`N125`)
- Support direct entry of full code (`N125`) as well
- Validate the range (Thule codes are typically N001–N250, but allow flexibility for future ranges)
- Show a large preview of the formatted key code as the user types

### 4. Key Code Search

A search bar at the top of the home screen that filters by:

- Key code (partial match, e.g., typing "12" shows N120, N125, N012)
- Nickname
- Product type

Useful when standing at the car with a key in hand: read the number stamped on it, search, instantly see which product it unlocks.

### 5. Quick Actions

- **Swipe to delete** a product entry
- **Long press** to duplicate (handy when adding multiple products with the same key code — Thule sells lock sets)
- **Share** a product's details as plain text (e.g., for sending to a partner: "Roof box — Key N125")

### 6. Key Code Grouping View

An alternative view that groups products by key code. Useful for users who've purchased a Thule One-Key System and converted multiple products to the same key:

```
N125
  ├── Roof box
  ├── Bike rack (towbar)
  └── Roof bars

N200
  └── Ski carrier
```

Toggle between "By Product" and "By Key" views via a segmented control or tab.

---

## Data Model

```
ThuleProduct
├── id: UUID
├── productType: ProductType (enum)
├── customProductName: String? (for "Other" type)
├── keyCode: String (e.g., "N125")
├── nickname: String?
├── notes: String?
├── numberOfLocks: Int (default 1)
├── createdAt: Date
├── updatedAt: Date
```

Storage: **SwiftData** with a single local persistent container. No CloudKit sync in v1 (see Future Considerations).

---

## Design Principles

- **Glanceable** — The key code should be the most prominent element on every row. Think large, monospaced, high-contrast.
- **Dark-mode friendly** — Many users will check this in dim car park lighting.
- **iOS-native** — SwiftUI, SF Symbols, standard navigation patterns. No custom chrome.
- **No onboarding** — Empty state shows a single "Add your first Thule product" button with a brief one-liner explanation.

---

## Technical Approach

| Area | Choice |
|---|---|
| UI | SwiftUI |
| Data persistence | SwiftData |
| Minimum target | iOS 17 |
| Architecture | Single-module, MVVM |
| Dependencies | None (zero third-party) |
| Distribution | App Store (free) |

Given the app's simplicity, a single Xcode project with no SPM modules is appropriate. MVVM with `@Observable` view models.

---

## Screens

1. **Product List** — Primary navigation view with search bar, segmented control (By Product / By Key), product rows, and an Add button.
2. **Add / Edit Product** — Sheet presentation with form fields and a large key code preview.
3. **Product Detail** — Optional detail view (could also be inline edit). Shows all fields with edit capability.
4. **Settings** — Minimal: app version, "About Thule Key Codes" info link, export/import data (JSON), reset all data.

---

## Empty State

When no products are added:

> **No Thule products yet**
> Tap + to add your first product and its key code.

Accompanied by a relevant SF Symbol illustration (e.g., `key.fill` or `lock.fill`).

---

## Future Considerations (Out of Scope for v1)

- **iCloud sync via CloudKit** — Sync across devices and share with family members.
- **Apple Watch companion** — Glanceable key code lookup from the wrist.
- **Widget** — Home/Lock Screen widget showing all key codes at a glance.
- **Photo attachment** — Snap a photo of the key stamp or the product for reference.
- **Barcode/NFC** — Some Thule products have barcodes; could auto-populate product type.
- **Thule One-Key System helper** — Guidance on which replacement lock cylinders to order when converting to a single key code.
- **Siri Shortcuts** — "Hey Siri, what's the key for my roof box?"
- **Multi-brand support** — Expand to Yakima, Küat, or other rack brands with similar key systems.

---

## Success Metrics

For a utility app this focused, success is simple:

- **Retention:** User opens the app more than once (i.e., they stored data and came back for it).
- **Completeness:** Average user adds 2+ products.
- **App Store rating:** 4.5+ stars.

---

## Monetisation

**Free, no ads, no IAP for v1.** The app is too small to justify a paywall. Potential v2 monetisation via a tip jar or a paid "Pro" tier unlocking iCloud sync / widgets / Watch app — but only if there's meaningful demand.

---

## Open Questions

1. Should the app support non-Thule lock systems from the start, or stay branded as a Thule-specific tool?
2. Is the N001–N250 range accurate for all current Thule key series, or are there newer extended ranges?
3. Should the app include a reference link to Thule's replacement key ordering page?
4. Naming: "Thule Key Tracker" may have trademark implications — alternatives include "Rack Keys", "Lock Book", "Key Code Vault".
