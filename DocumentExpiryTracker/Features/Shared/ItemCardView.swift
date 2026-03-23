import SwiftUI

struct ItemCardView: View {
    let item: TrackedItem

    var body: some View {
        let status = ItemAnalytics.status(for: item)
        let dueDate = ItemAnalytics.effectiveDueDate(for: item)

        HStack(alignment: .top, spacing: 14) {
            CategoryIconView(category: item.category, size: 22)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)

                        if !item.provider.isEmpty {
                            Text(item.provider)
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    VStack(alignment: .trailing, spacing: 6) {
                        StatusBadgeView(status: status, text: ItemAnalytics.countdownText(for: item))

                        if item.isRecurring {
                            Text(item.recurringInterval.title)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.88))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.purple.opacity(0.32))
                                .clipShape(Capsule())
                        }
                    }
                }

                HStack(spacing: 8) {
                    Text(item.category.title.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.textMuted)

                    if let amount = item.amount {
                        Text("\(AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode))\(item.isRecurring ? " / \(item.recurringInterval.shortTitle)" : "")")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                HStack(spacing: 8) {
                    Text("\(ItemAnalytics.actionLabel(for: item)) \(AppFormatters.shortDate.string(from: dueDate))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    if !item.attachments.isEmpty {
                        Label("\(item.attachments.count)", systemImage: "paperclip")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textMuted)
                .padding(.top, 4)
        }
        .appCardStyle()
    }
}
