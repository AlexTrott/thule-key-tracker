import SwiftUI

struct KeyCodeBadge: View {
    let code: String
    var style: Style = .row

    enum Style {
        case row
        case hero
        case groupHeader
        case formPreview
    }

    var body: some View {
        switch style {
        case .row:
            Text(code)
                .font(ThuleTheme.keyCodeFont(size: 28))
                .tracking(-1)
                .foregroundStyle(.thuleBlue)

        case .hero:
            Text(code)
                .font(ThuleTheme.keyCodeFont(size: 56))
                .tracking(-2)
                .foregroundStyle(.primary)

        case .groupHeader:
            Text(code)
                .font(ThuleTheme.keyCodeFont(size: 32))
                .tracking(-1)
                .foregroundStyle(.primary)

        case .formPreview:
            Text(code)
                .font(ThuleTheme.keyCodeFont(size: 56))
                .tracking(-2)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        KeyCodeBadge(code: "N125", style: .row)
        KeyCodeBadge(code: "N125", style: .hero)
        KeyCodeBadge(code: "N042", style: .groupHeader)
    }
    .padding()
}
