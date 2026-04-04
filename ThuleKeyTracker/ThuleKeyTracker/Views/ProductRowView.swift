import SwiftData
import SwiftUI

struct ProductRowView: View {
    let product: ThuleProduct

    var body: some View {
        HStack(spacing: 14) {
            ProductTypeIcon(productType: product.productType)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.displayName)
                    .font(.body.weight(.semibold))
                if product.nickname != nil {
                    Text(product.productType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            KeyCodeBadge(code: product.keyCode, style: .row)
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
