import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: productType.sfSymbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
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
