import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "No Thule Products Yet"), systemImage: "key.fill")
                .foregroundStyle(.thuleBlue)
        } description: {
            Text("Tap + to add your first product and its key code.")
        }
    }
}

#Preview {
    EmptyStateView()
}
