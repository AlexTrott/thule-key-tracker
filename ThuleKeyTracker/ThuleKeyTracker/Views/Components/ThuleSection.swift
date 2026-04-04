import SwiftUI

struct ThuleSection<Content: View>: View {
    let header: String?
    let footer: String?
    @ViewBuilder let content: () -> Content

    init(
        _ header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header {
                Text(header.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(0.5)
                    .foregroundStyle(ThuleTheme.secondaryText)
                    .padding(.horizontal, 20)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(ThuleTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: ThuleTheme.smallRadius))

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(ThuleTheme.secondaryText)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct ThuleRow<Content: View>: View {
    let showDivider: Bool
    @ViewBuilder let content: () -> Content

    init(showDivider: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.showDivider = showDivider
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
                .padding(.horizontal, ThuleTheme.cardPadding)
                .padding(.vertical, 14)
            if showDivider {
                Divider()
                    .padding(.leading, ThuleTheme.cardPadding)
            }
        }
    }
}

#Preview {
    ScrollView {
        ThuleSection("Product Info") {
            ThuleRow {
                HStack {
                    Text("Nickname")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Motion XT XL")
                }
            }
            ThuleRow(showDivider: false) {
                HStack {
                    Text("Locks")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("2")
                }
            }
        }
    }
    .padding()
    .background(ThuleTheme.background)
}
