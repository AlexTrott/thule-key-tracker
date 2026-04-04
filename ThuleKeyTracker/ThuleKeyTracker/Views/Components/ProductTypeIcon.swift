import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: productType.sfSymbol)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size + 16, height: size + 16)
            .background(.thuleBlue, in: RoundedRectangle(cornerRadius: (size + 16) * 0.28))
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
    .padding()
}
