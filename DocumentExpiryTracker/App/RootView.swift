import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var appLockManager: AppLockManager
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
            appLockManager.refreshAvailability()
            appLockManager.sceneDidBecomeActive(
                isEnabled: settings.isAppLockEnabled,
                isProUnlocked: purchaseManager.isProUnlocked,
                hasCompletedOnboarding: settings.hasCompletedOnboarding
            )
            WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await notificationManager.refreshStatus()
                await purchaseManager.refreshEntitlements()
                appLockManager.refreshAvailability()
                appLockManager.sceneDidBecomeActive(
                    isEnabled: settings.isAppLockEnabled,
                    isProUnlocked: purchaseManager.isProUnlocked,
                    hasCompletedOnboarding: settings.hasCompletedOnboarding
                )
                WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
            }
        }
        .overlay {
            if appLockManager.requiresUnlock {
                AppLockOverlayView()
            }
        }
        .appScreenBackground()
    }
}

private struct AppLockOverlayView: View {
    @EnvironmentObject private var appLockManager: AppLockManager

    var body: some View {
        ZStack {
            AppTheme.background.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.brandGradient)
                    .frame(width: 88, height: 88)
                    .overlay {
                        Image(systemName: appLockManager.biometryType == .faceID ? "faceid" : "lock.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }

                VStack(spacing: 8) {
                    Text("Locked")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Unlock with \(appLockManager.biometryTitle) to see your tracked renewals, documents, and subscriptions.")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button("Unlock") {
                    Task { _ = await appLockManager.unlock() }
                }
                .buttonStyle(AppFilledButtonStyle(isLarge: true))
                .frame(maxWidth: 260)

                if let error = appLockManager.lastError, !error.isEmpty {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(28)
            .frame(maxWidth: 360)
        }
        .transition(.opacity)
    }
}
