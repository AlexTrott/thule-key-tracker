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
