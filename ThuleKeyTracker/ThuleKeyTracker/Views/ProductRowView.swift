import SwiftData
import SwiftUI

struct ProductRowView: View {
    let product: ThuleProduct

    var body: some View {
        HStack(spacing: 14) {
            ProductTypeIcon(productType: product.productType)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.displayName)
                    .font(.system(size: 17, weight: .semibold))
                if product.nickname != nil {
                    Text(product.productType.displayName)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            KeyCodeBadge(code: product.keyCode, style: .row)
        }
        .padding(ThuleTheme.cardPadding)
        .background(ThuleTheme.card, in: RoundedRectangle(cornerRadius: ThuleTheme.cardRadius))
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
