import SwiftUI
import SwiftData

struct InsightsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query(sort: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]) private var items: [TrackedItem]

    let onUpgradeTapped: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Track your renewal patterns and recurring costs")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if purchaseManager.isProUnlocked {
                    proContent
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
            quickStatsCard(includeTotals: false)

            ZStack {
                VStack(spacing: 16) {
                    analyticsCard(title: "Recurring Costs") {
                        lockedRow(label: "Monthly", value: "$XXX.XX")
                        lockedRow(label: "Yearly", value: "$X,XXX.XX")
                    }
                    analyticsCard(title: "Category Breakdown") {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.fillSoft)
                                .frame(height: 18)
                        }
                    }
                }
                .blur(radius: 8)

                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppTheme.brandGradient)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.white)
                        }

                    VStack(spacing: 8) {
                        Text("Unlock Insights")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Get detailed analytics, recurring cost tracking, and premium overview cards.")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button("Upgrade to Pro") {
                        onUpgradeTapped()
                    }
                    .buttonStyle(AppFilledButtonStyle())
                    .accessibilityIdentifier("insights_upgrade")
                }
                .padding(28)
                .appCardStyle(padding: 28, radius: 24)
                .padding(.horizontal, 20)
            }
        }
    }

    private var proContent: some View {
        VStack(spacing: 16) {
            quickStatsCard(includeTotals: true)

            analyticsCard(title: "Recurring Costs") {
                metricRow(label: "Monthly", value: AppFormatters.currencyString(amount: ItemAnalytics.monthlyRecurringTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
                metricRow(label: "Yearly", value: AppFormatters.currencyString(amount: ItemAnalytics.yearlyRecurringTotal(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
                Divider().overlay(AppTheme.border)
                metricRow(label: "Estimated Annual Total", value: AppFormatters.currencyString(amount: ItemAnalytics.annualRecurringEstimate(from: items), currencyCode: Locale.current.currency?.identifier ?? "USD"))
            }

            analyticsCard(title: "Category Breakdown") {
                let breakdown = ItemAnalytics.categoryBreakdown(from: items)
                ForEach(breakdown, id: \.0.id) { category, count in
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
                                    .frame(width: proxy.size.width * CGFloat(Double(count) / Double(max(1, ItemAnalytics.activeItems(from: items).count))))
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }

            analyticsCard(title: "Next 30 Days") {
                metricRow(label: "Overdue", value: "\(ItemAnalytics.expiredItems(from: items).count)")
                metricRow(label: "Due in next 30 days", value: "\(ItemAnalytics.dueInNext(days: 30, items: items))")
                metricRow(label: "Due in next 7 days", value: "\(ItemAnalytics.dueInNext(days: 7, items: items))")
            }
        }
    }

    private func quickStatsCard(includeTotals: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.white)
                Text("Quick Stats")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                statTile(title: "Total Items", value: "\(ItemAnalytics.activeItems(from: items).count)")
                statTile(title: "Due in 30 Days", value: "\(ItemAnalytics.dueInNext(days: 30, items: items))")
                if includeTotals {
                    statTile(title: "Expired", value: "\(ItemAnalytics.expiredItems(from: items).count)")
                    statTile(title: "Due Soon", value: "\(ItemAnalytics.dueSoonItems(from: items).count)")
                } else {
                    statTile(title: "Due Soon", value: "\(ItemAnalytics.dueSoonItems(from: items).count)")
                    statTile(title: "Locked", value: "Pro")
                }
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
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private func lockedRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
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
}
