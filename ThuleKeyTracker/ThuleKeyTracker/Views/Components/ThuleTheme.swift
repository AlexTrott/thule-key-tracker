import SwiftUI

enum ThuleTheme {
    // MARK: - Colors (uses iOS semantic colors that match Stitch design exactly)

    /// Pure black in dark, system grouped background in light
    static let background = Color(.systemGroupedBackground)

    /// #1C1C1E in dark, white in light — for cards and surfaces
    static let card = Color(.secondarySystemGroupedBackground)

    /// #3A3A3C in dark, light gray in light — for dividers inside cards
    static let separator = Color(.separator)

    /// #8E8E93 — secondary text
    static let secondaryText = Color(.secondaryLabel)

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
