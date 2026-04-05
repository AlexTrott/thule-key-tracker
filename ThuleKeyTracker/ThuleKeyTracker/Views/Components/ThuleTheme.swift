import SwiftUI

enum ThuleTheme {
    // MARK: - Colors (adaptive light/dark)

    /// #F9F9F9 in light, #000000 in dark
    static let background = Color(.systemBackground)

    /// White in light, #1C1C1E in dark — card surfaces
    static let card = Color(.secondarySystemGroupedBackground)

    /// Dividers
    static let separator = Color(.separator)

    /// Secondary text
    static let secondaryText = Color(.secondaryLabel)

    /// Segmented control track — light gray in light, dark gray in dark
    static let segmentedTrack = Color(.systemFill)

    // MARK: - Typography

    /// Condensed bold title font — Thule brand feel
    static func titleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .default).width(.condensed)
    }

    /// Monospaced bold for key codes
    static func keyCodeFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }

    /// Label font — uppercase tracking style
    static func labelFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }

    // MARK: - Spacing

    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 28
    static let horizontalPadding: CGFloat = 16
    static let iconSize: CGFloat = 44

    // MARK: - Corner Radius

    static let cardRadius: CGFloat = 16
    static let smallRadius: CGFloat = 12
    static let searchRadius: CGFloat = 12
}
