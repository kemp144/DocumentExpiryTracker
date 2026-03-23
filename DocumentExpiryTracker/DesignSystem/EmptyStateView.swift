import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(systemImage: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 64, height: 64)
                .background(AppTheme.fillSoft)
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(AppFilledButtonStyle())
                    .frame(maxWidth: 220)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .appCardStyle(padding: 28, radius: 24)
    }
}
