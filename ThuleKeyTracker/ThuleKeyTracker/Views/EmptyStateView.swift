import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            String(localized: "No Thule Products Yet"),
            systemImage: "key.fill",
            description: Text("Tap + to add your first product and its key code.")
        )
    }
}

#Preview {
    EmptyStateView()
}
