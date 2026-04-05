import SwiftUI

struct ProductTypePickerView: View {
    @Binding var selectedType: ProductType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ProductType.allCases) { type in
                        Button {
                            selectedType = type
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ProductTypeIcon(productType: type, size: 40)
                                Text(type.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if type == selectedType {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.thuleBlue)
                                }
                            }
                            .padding(.horizontal, ThuleTheme.cardPadding)
                            .padding(.vertical, 12)
                        }
                        if type != ProductType.allCases.last {
                            Divider()
                                .padding(.leading, ThuleTheme.cardPadding + 54)
                        }
                    }
                }
                .background(ThuleTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: ThuleTheme.smallRadius))
                .padding(.horizontal, ThuleTheme.horizontalPadding)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "Product Type"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ProductTypePickerView(selectedType: .constant(.roofBox))
        .preferredColorScheme(.dark)
}
