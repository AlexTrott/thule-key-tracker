import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: productType.sfSymbol)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size * 2, height: size * 2)
            .background(.thuleBlue, in: Circle())
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
