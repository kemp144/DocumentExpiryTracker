import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]) private var items: [TrackedItem]

    let onAddTapped: () -> Void
    let onUpgradeTapped: (PaywallContext) -> Void

    private var activeItems: [TrackedItem] { ItemAnalytics.activeItems(from: items) }
    private var expiredItems: [TrackedItem] { ItemAnalytics.expiredItems(from: items) }
    private var dueSoonItems: [TrackedItem] { ItemAnalytics.dueSoonItems(from: items) }
    private var upcomingItems: [TrackedItem] {
        let urgentIDs = Set(dueSoonItems.map(\.id))
        return ItemAnalytics.upcomingWithinThirtyDays(from: items)
            .filter { !urgentIDs.contains($0.id) }
    }
    private var recurringItems: [TrackedItem] {
        activeItems.filter(\.isRecurring)
    }
    private var criticalItem: TrackedItem? {
        ItemAnalytics.criticalItem(from: items)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header

                if activeItems.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar.badge.plus",
                        title: "Track your first renewal",
                        message: "Keep passports, warranties, subscriptions, contracts, and insurance renewals in one calm place.",
                        actionTitle: "Add your first item",
                        action: onAddTapped
                    )
                    .padding(.top, 28)
                } else {
                    actionCard

                    if settings.shouldShowSoftUpgradePrompt && !purchaseManager.isProUnlocked {
                        softUpgradeCard
                    }

                    dueSoonSection
                    recurringSection
                    expiredSection

                    if !upcomingItems.isEmpty {
                        sectionHeader(title: "Coming Up", subtitle: "The next few renewals after your urgent items")

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
                Text("Stay ahead of expirations, renewals, and recurring costs")
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

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(heroEyebrow)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .textCase(.uppercase)
                    Text(heroTitle)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                    Text(heroSubtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .lineSpacing(2)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                Spacer(minLength: 12)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: heroSymbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }
            }

            HStack(spacing: 10) {
                heroStat(title: "Due soon", value: "\(dueSoonItems.count)")
                heroStat(title: "Active", value: "\(activeItems.count)")
                
                if !recurringItems.isEmpty {
                    heroStat(
                        title: "Monthly",
                        value: AppFormatters.formatMultiCurrency(
                            totals: ItemAnalytics.monthlyRecurringTotal(from: items),
                            compact: true
                        )
                    )
                } else if !expiredItems.isEmpty {
                    heroStat(title: "Expired", value: "\(expiredItems.count)")
                }
            }
        }
        .padding(20)
        .background(AppTheme.brandGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var softUpgradeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Go further with Pro")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    settings.dismissSoftUpgradePrompt(permanently: true)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.textMuted)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.fillSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text("Unlock widgets, multiple reminders, attachments, and room to track everything important.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(2)

            Button("See Pro Benefits") {
                settings.dismissSoftUpgradePrompt(permanently: true)
                onUpgradeTapped(.softUpgrade)
            }
            .buttonStyle(AppSecondaryButtonStyle())
            .accessibilityIdentifier("home_soft_upgrade")
        }
        .appCardStyle(padding: 20, radius: 24)
    }

    private var dueSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Due Soon", subtitle: "Focus on what needs attention next")

            if dueSoonItems.isEmpty {
                compactEmptyCard(
                    symbol: "checkmark.circle.fill",
                    title: "Nothing urgent",
                    message: "You are up to date for now."
                )
            } else {
                ForEach(dueSoonItems.prefix(4), id: \.id) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        ItemCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Recurring Costs", subtitle: "See the costs you are carrying month to month")

            if recurringItems.isEmpty {
                compactEmptyCard(
                    symbol: "repeat",
                    title: "No recurring items",
                    message: "Track subscriptions to see ongoing commitments."
                )
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            RecurringItemsListView(title: "Monthly Costs", items: ItemAnalytics.monthlyRecurringItems(from: items))
                        } label: {
                            recurringStat(title: "Monthly", totals: ItemAnalytics.monthlyRecurringTotal(from: items))
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink {
                            RecurringItemsListView(title: "Yearly Costs", items: ItemAnalytics.yearlyRecurringItems(from: items))
                        } label: {
                            recurringStat(title: "Yearly", totals: ItemAnalytics.yearlyRecurringTotal(from: items))
                        }
                        .buttonStyle(.plain)
                    }

                    let nextThirtyTotal = ItemAnalytics.recurringDueInNextThirtyDaysTotal(from: items)
                    if !nextThirtyTotal.isEmpty {
                        NavigationLink {
                            RecurringItemsListView(title: "Next 30 Days", items: ItemAnalytics.recurringDueInNextThirtyDaysItems(from: items))
                        } label: {
                            HStack {
                                Text("Next 30 days")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.textSecondary)
                                Spacer()
                                Text(AppFormatters.formatMultiCurrency(totals: nextThirtyTotal, compact: false))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .appCardStyle()
            }
        }
    }

    private var expiredSection: some View {
        Group {
            if !expiredItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "Expired", subtitle: "Older items that need to be renewed or archived")
                    ForEach(expiredItems.prefix(3), id: \.id) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            ItemCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var heroEyebrow: String {
        if !expiredItems.isEmpty { return "Needs attention" }
        if !dueSoonItems.isEmpty { return "Action dashboard" }
        return "All clear"
    }

    private var heroTitle: String {
        if !expiredItems.isEmpty {
            return "\(expiredItems.count) Expired"
        }
        if let criticalItem, !dueSoonItems.isEmpty {
            return ItemAnalytics.urgencyTitle(for: criticalItem)
        }
        return "Everything is calm"
    }

    private var heroSubtitle: String {
        if let criticalItem, !dueSoonItems.isEmpty || !expiredItems.isEmpty {
            let dueDate = ItemAnalytics.effectiveDueDate(for: criticalItem)
            let dateStr = AppFormatters.shortDate.string(from: dueDate)
            var amountStr = ""
            if let amount = criticalItem.amount {
                let currStr = AppFormatters.currencyString(amount: amount, currencyCode: criticalItem.currencyCode)
                amountStr = " · \(currStr)\(criticalItem.isRecurring ? "/\(criticalItem.recurringInterval.shortTitle)" : "")"
            }
            return "\(criticalItem.title)\n\(ItemAnalytics.actionLabel(for: criticalItem)) \(dateStr)\(amountStr)"
        }
        return "You are up to date on all renewals and expirations."
    }

    private var heroSymbol: String {
        if !expiredItems.isEmpty { return "exclamationmark.triangle.fill" }
        if !dueSoonItems.isEmpty { return "clock.fill" }
        return "checkmark.circle.fill"
    }

    private func heroStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.75))
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func recurringStat(title: String, totals: [String: Double]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Text(AppFormatters.formatMultiCurrency(totals: totals, compact: false))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.fillSoft)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func compactEmptyCard(symbol: String, title: String, message: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 44, height: 44)
                .background(AppTheme.fillSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .appCardStyle(padding: 16, radius: 20)
    }
}
