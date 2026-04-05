import SwiftUI

struct EmptyStateView: View {
    @State private var isPulsing = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(.thuleBlue.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isPulsing ? 1.15 : 1.0)
                    .opacity(isPulsing ? 0.0 : 1.0)

                // Icon circle
                Circle()
                    .fill(colorScheme == .dark
                        ? Color(.systemGray5)
                        : Color(.systemGray6))
                    .frame(width: 100, height: 100)

                Image(systemName: "key.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.thuleBlue)
            }
            .padding(.bottom, 8)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }

            Text(String(localized: "No Thule Products Yet"))
                .font(ThuleTheme.titleFont(size: 22))
                .tracking(0.5)

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

#Preview("Dark") {
    EmptyStateView()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    EmptyStateView()
        .preferredColorScheme(.light)
}
