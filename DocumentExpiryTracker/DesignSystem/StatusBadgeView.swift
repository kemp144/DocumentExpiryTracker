import SwiftUI

struct StatusBadgeView: View {
    let status: ItemStatus
    let text: String

    private var colors: (Color, Color) {
        switch status {
        case .expired:
            (AppTheme.danger.opacity(0.18), AppTheme.danger)
        case .dueToday, .dueSoon:
            (AppTheme.warning.opacity(0.18), AppTheme.warning)
        case .archived:
            (AppTheme.fillMuted, AppTheme.textSecondary)
        case .upcoming, .active:
            (AppTheme.fillMuted, AppTheme.textSecondary)
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(colors.1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(colors.0)
            .overlay(
                Capsule()
                    .stroke(colors.1.opacity(0.18), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}
