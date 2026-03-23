import SwiftUI
import SwiftData

struct AppTabContainerView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query private var allItems: [TrackedItem]

    @State private var selection: AppTab = .home
    @State private var showingAddSheet = false
    @State private var paywallContext: PaywallContext?

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home:
                    NavigationStack {
                        HomeView(onAddTapped: requestAdd, onUpgradeTapped: presentPaywall)
                    }
                case .items:
                    NavigationStack {
                        ItemsView(onAddTapped: requestAdd)
                    }
                case .insights:
                    NavigationStack {
                        InsightsView(onUpgradeTapped: { presentPaywall(.insights) })
                    }
                case .settings:
                    NavigationStack {
                        SettingsView(onUpgradeTapped: presentPaywall)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(selection: $selection)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ItemFormView(mode: .add)
        }
        .sheet(item: $paywallContext) { context in
            PaywallView(context: context)
        }
        .appScreenBackground()
    }

    private func requestAdd() {
        if FeatureGate.canAddItem(existingItemCount: allItems.count, isPro: purchaseManager.isProUnlocked) {
            showingAddSheet = true
        } else {
            presentPaywall(.itemLimit)
        }
    }

    private func presentPaywall(_ context: PaywallContext) {
        paywallContext = context
    }
}
