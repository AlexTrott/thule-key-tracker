import SwiftUI

enum ProductType: String, Codable, CaseIterable, Identifiable, Sendable {
    case roofBox
    case bikeRackTowbar
    case bikeRackRoof
    case bikeRackTailgate
    case roofBars
    case skiCarrier
    case kayakCarrier
    case boardCarrier
    case cargoCarrier
    case cargoBag
    case cableLock
    case lockCylinder
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
        case .skiCarrier: String(localized: "Ski/Snowboard Carrier")
        case .kayakCarrier: String(localized: "Kayak/Canoe Carrier")
        case .boardCarrier: String(localized: "Board Carrier")
        case .cargoCarrier: String(localized: "Cargo Carrier")
        case .cargoBag: String(localized: "Cargo Bag")
        case .cableLock: String(localized: "Cable Lock")
        case .lockCylinder: String(localized: "Lock Cylinder")
        case .trailerLock: String(localized: "Trailer Lock")
        case .other: String(localized: "Other")
        }
    }

    /// Custom bespoke icon asset name (Recraft-generated pictograms)
    var iconAsset: String {
        switch self {
        case .roofBox: "roofBoxIcon"
        case .bikeRackTowbar: "bikeRackTowbarIcon"
        case .bikeRackRoof: "bikeRackRoofIcon"
        case .bikeRackTailgate: "bikeRackTailgateIcon"
        case .roofBars: "roofBarsIcon"
        case .skiCarrier: "skiCarrierIcon"
        case .kayakCarrier: "kayakCarrierIcon"
        case .boardCarrier: "boardCarrierIcon"
        case .cargoCarrier: "cargoCarrierIcon"
        case .cargoBag: "cargoBagIcon"
        case .cableLock: "cableLockIcon"
        case .lockCylinder: "lockCylinderIcon"
        case .trailerLock: "trailerLockIcon"
        case .other: "otherIcon"
        }
    }

    /// The icon image to use — SF Symbol "bicycle" for bike rack types, custom asset for everything else
    var iconImage: Image {
        switch self {
        case .bikeRackTowbar, .bikeRackRoof, .bikeRackTailgate:
            Image(systemName: "bicycle")
        default:
            Image(iconAsset)
        }
    }

    /// SF Symbol fallback for system contexts (e.g. menus, pickers)
    var sfSymbol: String {
        switch self {
        case .roofBox: "shippingbox.fill"
        case .bikeRackTowbar: "bicycle"
        case .bikeRackRoof: "bicycle"
        case .bikeRackTailgate: "bicycle"
        case .roofBars: "rectangle.split.1x2"
        case .skiCarrier: "snowflake"
        case .kayakCarrier: "figure.rowing"
        case .boardCarrier: "figure.surfing"
        case .cargoCarrier: "cart.fill"
        case .cargoBag: "bag.fill"
        case .cableLock: "cable.connector"
        case .lockCylinder: "lock.circle"
        case .trailerLock: "lock.fill"
        case .other: "wrench.and.screwdriver.fill"
        }
    }
}
