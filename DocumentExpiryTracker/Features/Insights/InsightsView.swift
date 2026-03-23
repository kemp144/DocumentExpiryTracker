import SwiftUI
import SwiftData

struct InsightsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query(sort: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]) private var items: [TrackedItem]

    let onUpgradeTapped: () -> Void

    private var activeItems: [TrackedItem] { ItemAnalytics.activeItems(from: items) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("See renewal load, recurring costs, and where your attention goes next")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if purchaseManager.isProUnlocked {
                    if activeItems.isEmpty {
                        EmptyStateView(
                            systemImage: "chart.bar.xaxis",
                            title: "Insights appear as you track more",
                            message: "Add a few renewals or subscriptions and this tab will start surfacing meaningful patterns."
                        )
                    } else {
                        proContent
                    }
                } else {
                    lockedContent
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var lockedContent: some View {
        VStack(spacing: 16) {
            quickStatsCard(includePremiumMetrics: false)

            VStack(alignment: .leading, spacing: 14) {
                Text("With Pro, Insights helps you understand recurring costs, renewal pressure, and which categories need the most attention.")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)

                Button("Unlock Advanced Insights") {
                    onUpgradeTapped()
                }
                .buttonStyle(AppFilledButtonStyle())
                .accessibilityIdentifier("insights_upgrade")
            }
            .appCardStyle(padding: 22, radius: 24)

            analyticsCard(title: "Preview") {
                metricRow(label: "Total tracked items", value: "\(activeItems.count)")
                metricRow(label: "Due in next 30 days", value: "\(ItemAnalytics.dueInNext(days: 30, items: items))")
                metricRow(label: "Recurring monthly total", value: "Pro")
                metricRow(label: "Highest recurring cost", value: "Pro")
            }
        }
    }

    private var proContent: some View {
        VStack(spacing: 16) {
            quickStatsCard(includePremiumMetrics: true)

            analyticsCard(title: "Recurring Costs") {
                metricRow(label: "Monthly total", value: AppFormatters.currencyString(amount: ItemAnalytics.monthlyRecurringTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
                metricRow(label: "Yearly total", value: AppFormatters.currencyString(amount: ItemAnalytics.yearlyRecurringTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
                metricRow(label: "Estimated annual load", value: AppFormatters.currencyString(amount: ItemAnalytics.annualRecurringEstimate(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
                metricRow(label: "Next 30 days", value: AppFormatters.currencyString(amount: ItemAnalytics.recurringDueInNextThirtyDaysTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
            }

            analyticsCard(title: "Renewal Pressure") {
                metricRow(label: "Due in next 30 days", value: "\(ItemAnalytics.dueInNext(days: 30, items: items))")
                metricRow(label: "Due in next 7 days", value: "\(ItemAnalytics.dueInNext(days: 7, items: items))")
                metricRow(label: "Expired", value: "\(ItemAnalytics.expiredItems(from: items).count)")
                metricRow(label: "Renewal load this month", value: "\(ItemAnalytics.renewalLoadThisMonth(from: items))")
            }

            analyticsCard(title: "Category Breakdown") {
                ForEach(ItemAnalytics.categoryBreakdown(from: items), id: \.0.id) { category, count in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(category.title)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("\(count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(AppTheme.fillSoft)
                                Capsule().fill(color(for: category))
                                    .frame(width: proxy.size.width * CGFloat(Double(count) / Double(max(1, activeItems.count))))
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }

            analyticsCard(title: "Highlights") {
                metricRow(
                    label: "Highest recurring cost",
                    value: highestRecurringCostSummary
                )
                metricRow(label: "Expiring documents", value: "\(ItemAnalytics.expiringDocumentsCount(from: items))")
                metricRow(label: "Next critical item", value: ItemAnalytics.criticalItem(from: items)?.title ?? "None")
            }
        }
    }

    private func quickStatsCard(includePremiumMetrics: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.white)
                Text("Quick Stats")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                statTile(title: "Tracked Items", value: "\(activeItems.count)")
                statTile(title: "Due Soon", value: "\(ItemAnalytics.dueSoonItems(from: items).count)")
                statTile(title: "Expired", value: "\(ItemAnalytics.expiredItems(from: items).count)")
                statTile(
                    title: includePremiumMetrics ? "Monthly Total" : "Advanced",
                    value: includePremiumMetrics
                        ? AppFormatters.compactCurrencyString(amount: ItemAnalytics.monthlyRecurringTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD")
                        : "Pro"
                )
            }
        }
        .padding(20)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func statTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.74))
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func analyticsCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            content()
        }
        .appCardStyle(padding: 20, radius: 24)
    }

    private func metricRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func color(for category: ItemCategory) -> Color {
        switch category {
        case .document: AppTheme.primary
        case .subscription: AppTheme.purple
        case .contract: AppTheme.success
        case .warranty: AppTheme.warning
        case .insurance: AppTheme.danger
        case .other: AppTheme.textSecondary
        }
    }

    private var highestRecurringCostSummary: String {
        guard let item = ItemAnalytics.highestRecurringCostItem(from: items),
              let amount = item.amount
        else {
            return "No recurring costs"
        }

        return "\(item.title) • \(AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode))"
    }
}
