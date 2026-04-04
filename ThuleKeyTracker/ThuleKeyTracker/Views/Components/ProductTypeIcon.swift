import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: productType.sfSymbol)
            .font(.system(size: size))
            .foregroundStyle(.accent)
            .frame(width: size + 8, height: size + 8)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(ProductType.allCases) { type in
            HStack {
                ProductTypeIcon(productType: type)
                Text(type.displayName)
            }
        }
    }
}
