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
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        case .hero:
            Text(code)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .tracking(-1)
                .foregroundStyle(.primary)
        case .groupHeader:
            Text(code)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.thuleBlue)
        case .formPreview:
            Text(code)
                .font(.system(size: 52, weight: .bold, design: .monospaced))
                .tracking(-1)
                .foregroundStyle(.thuleBlue)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        KeyCodeBadge(code: "N125", style: .row)
        KeyCodeBadge(code: "N125", style: .hero)
        KeyCodeBadge(code: "N042", style: .groupHeader)
        KeyCodeBadge(code: "N200", style: .formPreview)
    }
    .padding()
}
