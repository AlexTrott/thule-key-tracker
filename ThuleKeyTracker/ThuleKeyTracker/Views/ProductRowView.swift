import SwiftData
import SwiftUI

struct ProductRowView: View {
    let product: ThuleProduct

    var body: some View {
        HStack(spacing: 12) {
            ProductTypeIcon(productType: product.productType)

            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(.headline)
                if product.nickname != nil {
                    Text(product.productType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            KeyCodeBadge(code: product.keyCode)
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
