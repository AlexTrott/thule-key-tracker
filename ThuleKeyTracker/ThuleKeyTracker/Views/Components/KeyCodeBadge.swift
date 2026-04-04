import SwiftUI

struct KeyCodeBadge: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.title.monospaced().bold())
            .foregroundStyle(.primary)
    }
}

#Preview {
    KeyCodeBadge(code: "N125")
}
