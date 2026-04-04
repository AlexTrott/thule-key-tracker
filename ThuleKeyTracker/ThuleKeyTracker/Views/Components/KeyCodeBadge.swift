import SwiftUI

struct KeyCodeBadge: View {
    let code: String
    var style: Style = .row

    enum Style {
        case row
        case hero
        case groupHeader
    }

    var body: some View {
        switch style {
        case .row:
            Text(code)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(.thuleBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.thuleBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        case .hero:
            Text(code)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(.thuleBlue)
                .padding(.vertical, 8)
        case .groupHeader:
            Text(code)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.thuleBlue)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        KeyCodeBadge(code: "N125", style: .row)
        KeyCodeBadge(code: "N125", style: .hero)
        KeyCodeBadge(code: "N042", style: .groupHeader)
    }
    .padding()
}
