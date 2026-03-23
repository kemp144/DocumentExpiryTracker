import SwiftUI

struct ItemCardView: View {
    let item: TrackedItem

    var body: some View {
        let status = ItemAnalytics.status(for: item)

        HStack(alignment: .top, spacing: 12) {
            CategoryIconView(category: item.category)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
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

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textMuted)
                        .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    StatusBadgeView(status: status, text: ItemAnalytics.countdownText(for: item))

                    if let amount = item.amount {
                        Text("\(AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode))\(item.isRecurring ? " / \(item.recurringInterval.shortTitle)" : "")")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Text("Due \(AppFormatters.shortDate.string(from: item.dueDate))")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textMuted)
            }

            Spacer(minLength: 0)
        }
        .appCardStyle()
    }
}
