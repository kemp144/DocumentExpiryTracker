import SwiftUI

struct CategoryIconView: View {
    let category: ItemCategory
    var size: CGFloat = 20

    private var color: Color {
        switch category {
        case .document: AppTheme.primary
        case .subscription: AppTheme.purple
        case .contract: AppTheme.success
        case .warranty: AppTheme.warning
        case .insurance: AppTheme.danger
        case .other: AppTheme.textSecondary
        }
    }

    var body: some View {
        Image(systemName: category.symbolName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size + 20, height: size + 20)
            .background(color.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
