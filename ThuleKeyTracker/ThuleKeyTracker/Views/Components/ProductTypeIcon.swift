import SwiftUI

struct ProductTypeIcon: View {
    let productType: ProductType
    var size: CGFloat = 44

    var body: some View {
        productType.iconImage
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .padding(size * 0.22)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(.thuleBlue, in: Circle())
            .shadow(color: .thuleBlue.opacity(0.3), radius: 6, y: 2)
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
    .preferredColorScheme(.dark)
}
