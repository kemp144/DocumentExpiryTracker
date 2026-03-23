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
            VStack(alignment: .leading, spacing: 20) {
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
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(heroEyebrow)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.72))
                    Text(heroTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                    Text(heroSubtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .lineLimit(3)
                }
                Spacer(minLength: 12)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: heroSymbol)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }
            }

            if let criticalItem {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next: \(criticalItem.title)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                    HStack(spacing: 10) {
                        Text(ItemAnalytics.urgencyTitle(for: criticalItem))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.16))
                            .clipShape(Capsule())

                        if let amount = criticalItem.amount {
                            Text(AppFormatters.currencyString(amount: amount, currencyCode: criticalItem.currencyCode))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.88))
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                heroStat(title: "Due soon", value: "\(dueSoonItems.count)")
                heroStat(title: "Active", value: "\(activeItems.count)")
                heroStat(title: "Expired", value: "\(expiredItems.count)")
                if !recurringItems.isEmpty {
                    heroStat(
                        title: "Monthly",
                        value: AppFormatters.compactCurrencyString(
                            amount: ItemAnalytics.monthlyRecurringTotal(from: items),
                            currencyCode: Locale.current.currency?.identifier ?? "USD"
                        )
                    )
                }
            }
        }
        .padding(22)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
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
            .buttonStyle(AppFilledButtonStyle())
            .accessibilityIdentifier("home_soft_upgrade")
        }
        .appCardStyle(padding: 20, radius: 24)
    }

    private var dueSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Due Soon", subtitle: dueSoonItems.isEmpty ? "No urgent renewals right now" : "Focus on what needs attention next")

            if dueSoonItems.isEmpty {
                compactEmptyCard(
                    symbol: "checkmark.circle.fill",
                    title: "Nothing urgent",
                    message: "You are up to date for now. Add more items or enjoy the quiet."
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
            sectionHeader(title: "Recurring Costs", subtitle: recurringItems.isEmpty ? "No recurring subscriptions or renewals yet" : "See the costs you are carrying month to month")

            if recurringItems.isEmpty {
                compactEmptyCard(
                    symbol: "repeat",
                    title: "No recurring items",
                    message: "Track Netflix, phone contracts, and insurance renewals to see your ongoing commitments."
                )
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        recurringStat(title: "Monthly", value: ItemAnalytics.monthlyRecurringTotal(from: items))
                        recurringStat(title: "Yearly", value: ItemAnalytics.yearlyRecurringTotal(from: items))
                    }

                    let nextThirtyTotal = ItemAnalytics.recurringDueInNextThirtyDaysTotal(from: items)
                    if nextThirtyTotal > 0 {
                        HStack {
                            Text("Next 30 days")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            Text(AppFormatters.currencyString(amount: nextThirtyTotal, currencyCode: Locale.current.currency?.identifier ?? "USD"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                }
                .appCardStyle()
            }
        }
    }

    private var expiredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Expired", subtitle: expiredItems.isEmpty ? "Everything active is still current" : "Older items that need to be renewed or archived")

            if expiredItems.isEmpty {
                compactEmptyCard(
                    symbol: "sparkles",
                    title: "All clear",
                    message: "Nothing in your tracker is currently expired."
                )
            } else {
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

    private var heroEyebrow: String {
        if !expiredItems.isEmpty { return "Needs attention" }
        if !dueSoonItems.isEmpty { return "Action dashboard" }
        return "All tracked items are up to date"
    }

    private var heroTitle: String {
        if !expiredItems.isEmpty {
            return "\(expiredItems.count) expired"
        }
        if let criticalItem, !dueSoonItems.isEmpty {
            return ItemAnalytics.urgencyTitle(for: criticalItem)
        }
        return "Everything looks calm"
    }

    private var heroSubtitle: String {
        if let criticalItem {
            let dueDate = ItemAnalytics.effectiveDueDate(for: criticalItem)
            return "\(criticalItem.title) • \(ItemAnalytics.actionLabel(for: criticalItem)) \(AppFormatters.shortDate.string(from: dueDate))"
        }
        return "Keep tracking renewals, subscriptions, contracts, and warranties in one place."
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
                .foregroundStyle(Color.white.opacity(0.68))
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func recurringStat(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Text(AppFormatters.currencyString(amount: value, currencyCode: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(size: 20, weight: .semibold))
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 40, height: 40)
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
        .appCardStyle(padding: 16, radius: 22)
    }
}
