import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var hasBootstrapped = false

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                AppTabContainerView()
            } else {
                OnboardingFlowView()
            }
        }
        .task {
            guard !hasBootstrapped else { return }
            hasBootstrapped = true
            AppBootstrapper.prepare(context: modelContext, settings: settings)
            await notificationManager.refreshStatus()
            await purchaseManager.loadProduct()
            await purchaseManager.refreshEntitlements()
            WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await notificationManager.refreshStatus()
                await purchaseManager.refreshEntitlements()
                WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
            }
        }
        .appScreenBackground()
    }
}
