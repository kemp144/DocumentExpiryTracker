import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query(sort: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]) private var items: [TrackedItem]

    let onAddTapped: () -> Void

    private var activeItems: [TrackedItem] { ItemAnalytics.activeItems(from: items) }
    private var expiredItems: [TrackedItem] { ItemAnalytics.expiredItems(from: items) }
    private var dueSoonItems: [TrackedItem] { ItemAnalytics.dueSoonItems(from: items) }
    private var upcomingItems: [TrackedItem] {
        ItemAnalytics.upcomingWithinThirtyDays(from: items)
            .filter { ItemAnalytics.status(for: $0) != .expired && ItemAnalytics.status(for: $0) != .dueSoon && ItemAnalytics.status(for: $0) != .dueToday }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header

                if activeItems.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar.badge.plus",
                        title: "No items yet",
                        message: "Add your first document, subscription, or renewal to get started.",
                        actionTitle: "Add First Item",
                        action: onAddTapped
                    )
                    .padding(.top, 36)
                } else {
                    overviewCard

                    if !expiredItems.isEmpty {
                        section(title: "Expired", count: expiredItems.count, color: AppTheme.danger, symbol: "exclamationmark.triangle.fill", items: expiredItems)
                    }

                    if !dueSoonItems.isEmpty {
                        section(title: "Due Soon", count: dueSoonItems.count, color: AppTheme.warning, symbol: "clock.fill", items: dueSoonItems)
                    }

                    if !upcomingItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming This Month")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)

                            ForEach(upcomingItems.prefix(3), id: \.id) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    ItemCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    recurringSummary

                    Button {
                        onAddTapped()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add New Item")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .foregroundStyle(AppTheme.primary)
                        .padding(.vertical, 16)
                    }
                    .background(AppTheme.elevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .accessibilityIdentifier("home_add")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Track what matters, stay organized")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Button {
                onAddTapped()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("home_header_add")
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overview")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text("\(activeItems.count) Items")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.white)
                    }
            }

            HStack {
                overviewStat(title: "Expired", value: expiredItems.count)
                Spacer()
                overviewStat(title: "Due Soon", value: dueSoonItems.count)
                Spacer()
                overviewStat(title: "Active", value: max(0, activeItems.count - expiredItems.count - dueSoonItems.count))
            }
        }
        .padding(22)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var recurringSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recurring Costs")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 12) {
                recurringStat(title: "Monthly", value: ItemAnalytics.monthlyRecurringTotal(from: items))
                recurringStat(title: "Yearly", value: ItemAnalytics.yearlyRecurringTotal(from: items))
            }
        }
        .appCardStyle()
    }

    private func recurringStat(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Text(AppFormatters.currencyString(amount: value, currencyCode: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.fillSoft)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func section(title: String, count: Int, color: Color, symbol: String, items: [TrackedItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("\(count)")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(items, id: \.id) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    ItemCardView(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func overviewStat(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.64))
            Text("\(value)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.white)
        }
    }
}
