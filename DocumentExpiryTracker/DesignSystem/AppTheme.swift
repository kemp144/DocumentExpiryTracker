import SwiftUI

enum AppTheme {
    static let background = Color(hex: "0A0A0A")
    static let elevated = Color(hex: "1C1C1E")
    static let elevatedSecondary = Color(hex: "2C2C2E")
    static let primary = Color(hex: "0A84FF")
    static let primaryDeep = Color(hex: "0066CC")
    static let purple = Color(hex: "5E5CE6")
    static let success = Color(hex: "30D158")
    static let warning = Color(hex: "FF9F0A")
    static let danger = Color(hex: "FF453A")
    static let textPrimary = Color(hex: "F5F5F7")
    static let textSecondary = Color(hex: "98989D")
    static let textMuted = Color.white.opacity(0.45)
    static let border = Color.white.opacity(0.10)
    static let fillSoft = Color.white.opacity(0.05)
    static let fillMuted = Color.white.opacity(0.08)

    static let brandGradient = LinearGradient(
        colors: [primary, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [primary, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

extension View {
    func appScreenBackground() -> some View {
        self.background(AppTheme.background.ignoresSafeArea())
    }

    func appCardStyle(padding: CGFloat = 16, radius: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(AppTheme.elevated)
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

struct AppFilledButtonStyle: ButtonStyle {
    let isLarge: Bool

    init(isLarge: Bool = false) {
        self.isLarge = isLarge
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isLarge ? 17 : 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isLarge ? 24 : 20)
            .padding(.vertical, isLarge ? 15 : 12)
            .background(configuration.isPressed ? AppTheme.primaryDeep : AppTheme.primary)
            .foregroundStyle(Color.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AppSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.elevatedSecondary.opacity(configuration.isPressed ? 1 : 0.7))
            .foregroundStyle(AppTheme.textPrimary)
            .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
            .clipShape(Capsule())
    }
}
