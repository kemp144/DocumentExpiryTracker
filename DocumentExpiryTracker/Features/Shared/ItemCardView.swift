import SwiftUI

struct ItemCardView: View {
    let item: TrackedItem

    enum Chip: Identifiable {
        case status(ItemStatus, String)
        case amount(Double, String)
        case recurring(String)
        case category(String)
        
        var id: String {
            switch self {
            case .status(let status, let text): "status_\(status.rawValue)_\(text)"
            case .amount(let val, let cur): "amount_\(val)_\(cur)"
            case .recurring(let val): "rec_\(val)"
            case .category(let val): "cat_\(val)"
            }
        }
    }
    
    var body: some View {
        let status = ItemAnalytics.status(for: item)
        let dueDate = ItemAnalytics.effectiveDueDate(for: item)

        HStack(alignment: .center, spacing: 14) {
            CategoryIconView(category: item.category, size: 32)

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    if !item.provider.isEmpty {
                        Text(item.provider)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 6) {
                        Text("\(ItemAnalytics.actionLabel(for: item)) \(AppFormatters.shortDate.string(from: dueDate))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        if !item.attachments.isEmpty {
                            Image(systemName: "paperclip")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    }
                }

                HStack(spacing: 6) {
                    let chips = buildChips(status: status)
                    let displayChips = chips.prefix(3)
                    
                    ForEach(displayChips) { chip in
                        chipView(for: chip)
                    }
                    
                    if chips.count > 3 {
                        Text("+\(chips.count - 3)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.fillSoft)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textMuted)
        }
        .appCardStyle(padding: 16, radius: 20)
    }
    
    private func buildChips(status: ItemStatus) -> [Chip] {
        var chips: [Chip] = []
        chips.append(.status(status, ItemAnalytics.countdownText(for: item)))
        
        if let amount = item.amount {
            chips.append(.amount(amount, item.currencyCode))
        }
        if item.isRecurring {
            chips.append(.recurring(item.recurringInterval.title))
        }
        chips.append(.category(item.category.title))
        return chips
    }
    
    @ViewBuilder
    private func chipView(for chip: Chip) -> some View {
        switch chip {
        case .status(let status, let text):
            StatusBadgeView(status: status, text: text)
        case .amount(let amount, let currency):
            Text(AppFormatters.currencyString(amount: amount, currencyCode: currency))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.fillSoft)
                .clipShape(Capsule())
        case .recurring(let text):
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.9))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.purple.opacity(0.3))
                .clipShape(Capsule())
        case .category(let text):
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.fillSoft)
                .clipShape(Capsule())
        }
    }
}
