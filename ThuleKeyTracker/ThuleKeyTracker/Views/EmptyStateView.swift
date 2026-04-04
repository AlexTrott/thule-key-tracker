import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundStyle(.thuleBlue)
                .padding(.bottom, 8)

            Text(String(localized: "No Thule Products Yet"))
                .font(.title2.weight(.bold))

            Text("Tap + to add your first product and its key code.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThuleTheme.background)
    }
}

#Preview {
    EmptyStateView()
}
