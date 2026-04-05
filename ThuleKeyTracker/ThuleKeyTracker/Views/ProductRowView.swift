import SwiftData
import SwiftUI

struct ProductRowView: View {
    let product: ThuleProduct
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            ProductTypeIcon(productType: product.productType)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.displayName)
                    .font(.system(size: 17, weight: .semibold))
                Text(product.productType.displayName.uppercased())
                    .font(ThuleTheme.labelFont(size: 12))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            KeyCodeBadge(code: product.keyCode, style: .row)
        }
        .padding(ThuleTheme.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                .fill(ThuleTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: ThuleTheme.cardRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [.white.opacity(0.08), .white.opacity(0.02)]
                                    : [.black.opacity(0.06), .black.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                    radius: 8, y: 2
                )
        }
    }
}

#Preview {
    VStack(spacing: ThuleTheme.cardSpacing) {
        ForEach(PreviewSampleData.sampleProducts) { product in
            ProductRowView(product: product)
        }
    }
    .padding(.horizontal, ThuleTheme.horizontalPadding)
    .frame(maxWidth: .infinity)
    .background(ThuleTheme.background)
    .modelContainer(PreviewSampleData.container)
}
