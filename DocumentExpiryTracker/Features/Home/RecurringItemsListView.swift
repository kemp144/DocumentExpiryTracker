import SwiftUI
import SwiftData

struct RecurringItemsListView: View {
    let title: String
    let items: [TrackedItem]

    private var subtitle: String {
        switch title {
        case "Monthly Costs": "Items billed every month with a set amount"
        case "Yearly Costs": "Items billed once per year with a set amount"
        case "Next 30 Days": "Recurring items due within the next 30 days"
        default: "Recurring items only — one-time expenses are excluded"
        }
    }

    private var total: [String: Double] {
        var totals: [String: Double] = [:]
        for item in items {
            guard let amount = item.amount else { continue }
            totals[item.currencyCode, default: 0] += amount
        }
        return totals
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                        if !total.isEmpty {
                            Text("Total: \(AppFormatters.formatMultiCurrency(totals: total))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                if items.isEmpty {
                    EmptyStateView(
                        systemImage: "repeat",
                        title: "No items here",
                        message: "No recurring items with a set amount match this filter."
                    )
                    .padding(.top, 36)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                ItemCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
