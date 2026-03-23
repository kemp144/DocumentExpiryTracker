import StoreKit
import SwiftData
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var appLockManager: AppLockManager
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TrackedItem]

    let onUpgradeTapped: (PaywallContext) -> Void

    @State private var statusMessage: String?
    @State private var showingAbout = false
    @State private var showingResetConfirmation = false

    private var iCloudStatus: ICloudSyncStatus {
        ICloudSyncStatusService.status(isProUnlocked: purchaseManager.isProUnlocked)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Privacy-first tracking for renewals, subscriptions, and important due dates")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                privacyHero
                notificationsSection
                preferencesSection
                premiumSection
                privacySection
                supportSection
                #if DEBUG
                developerSection
                #endif

                if let statusMessage {
                    Text(statusMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                }

                VStack(spacing: 4) {
                    Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Made with care for privacy and peace of mind")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAbout) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Document Expiry Tracker helps you stay ahead of renewals, subscriptions, warranties, insurance, contracts, and other important due dates. The app is local-first, privacy-first, and designed to feel calm instead of noisy.")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineSpacing(3)

                        Text("Pro unlocks extra protection like widgets, attachments, Face ID lock, advanced insights, and room to track everything important in one place.")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showingAbout = false
                        }
                    }
                }
            }
        }
        .onAppear {
            appLockManager.refreshAvailability()
        }
        .confirmationDialog("Reset All Data", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Delete All Items", role: .destructive) {
                for item in allItems { modelContext.delete(item) }
                statusMessage = "All data deleted."
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(allItems.count) tracked items. This action cannot be undone.")
        }
    }

    private var privacyHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.white)
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Private by default")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("Your tracking stays local-first")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                bulletPoint("Stored securely on your device")
                bulletPoint("Local reminders only")
                bulletPoint("No account or sign-in required")
            }
            .padding(.top, 4)
        }
        .padding(22)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.9))
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.88))
        }
    }

    private var notificationsSection: some View {
        settingsCard(title: "Notifications") {
            settingsRow(
                symbol: "bell.fill",
                title: "Status",
                subtitle: notificationManager.summaryMessage,
                value: notificationManager.summaryTitle
            )

            if notificationManager.authorizationStatus == .denied {
                Divider().overlay(AppTheme.border)
                Button {
                    openAppSettings()
                } label: {
                    settingsRow(
                        symbol: "arrow.up.forward.app.fill",
                        title: "Open iPhone Settings",
                        subtitle: "Turn notifications back on for timely reminders."
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().overlay(AppTheme.border)
            settingsRow(
                symbol: "clock.badge",
                title: "Reminder options",
                subtitle: "Same day, 1 day, 3 days, 7 days, or 30 days before an item is due."
            )
        }
    }

    private var preferencesSection: some View {
        settingsCard(title: "Preferences") {
            HStack(spacing: 12) {
                leadingIcon(symbol: "circle.lefthalf.filled")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appearance")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Choose how the app should look on your device.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Picker("Appearance", selection: Binding(
                    get: { settings.appearanceMode },
                    set: { settings.appearanceMode = $0 }
                )) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppTheme.primary)
            }
            .padding(16)

            Divider().overlay(AppTheme.border)

            HStack(spacing: 12) {
                leadingIcon(symbol: "dollarsign.circle.fill")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Default Currency")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Used for new items and primary totals.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Picker("Currency", selection: $settings.defaultCurrency) {
                    ForEach(FeatureGate.availableCurrencies(isPro: true), id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppTheme.primary)
            }
            .padding(16)

            Divider().overlay(AppTheme.border)

            HStack(spacing: 12) {
                leadingIcon(symbol: "faceid")
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Lock")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(appLockSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { settings.isAppLockEnabled },
                    set: { updateAppLock(enabled: $0) }
                ))
                .labelsHidden()
                .disabled(!appLockManager.isBiometricsAvailable && !settings.isAppLockEnabled)
                .tint(AppTheme.primary)
            }
            .padding(16)
        }
    }

    private var premiumSection: some View {
        settingsCard(title: "Premium") {
            Button {
                if !purchaseManager.isProUnlocked {
                    onUpgradeTapped(.general)
                }
            } label: {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.brandGradient)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.white)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(purchaseManager.isProUnlocked ? "Document Expiry Tracker Pro" : "Upgrade to Pro")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(purchaseManager.isProUnlocked ? "Unlocked on this device." : "Unlock unlimited tracking, widgets, attachments, Face ID lock, and advanced insights.")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    if !purchaseManager.isProUnlocked {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.textMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_upgrade")

            Divider().overlay(AppTheme.border)

            Button {
                if purchaseManager.isProUnlocked {
                    statusMessage = "Widgets are available from the Home Screen widget gallery."
                } else {
                    onUpgradeTapped(.widgets)
                }
            } label: {
                settingsRow(
                    symbol: "rectangle.grid.2x2.fill",
                    title: "Home Screen Widgets",
                    subtitle: purchaseManager.isProUnlocked ? "Small and medium widgets are ready for your Home Screen." : "See your next due item and renewal summary without opening the app.",
                    value: purchaseManager.isProUnlocked ? "Ready" : "Pro"
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                if purchaseManager.isProUnlocked {
                    statusMessage = iCloudStatus.message
                } else {
                    onUpgradeTapped(.cloudSync)
                }
            } label: {
                settingsRow(
                    symbol: "icloud.fill",
                    title: "iCloud Backup & Sync",
                    subtitle: iCloudStatus.message,
                    value: purchaseManager.isProUnlocked ? iCloudStatus.title : "Pro"
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                Task {
                    let restored = await purchaseManager.restore()
                    statusMessage = restored ? "Purchases restored." : (purchaseManager.lastError ?? "Nothing was restored.")
                }
            } label: {
                settingsRow(
                    symbol: "arrow.clockwise",
                    title: "Restore Purchases",
                    subtitle: "Re-check your lifetime Pro unlock."
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_restore")
        }
    }

    private var privacySection: some View {
        settingsCard(title: "Data & Privacy") {
            settingsRow(
                symbol: "hand.raised.fill",
                title: "Local-first storage",
                subtitle: "Your data stays on-device and the app remains fully usable offline."
            )
            Divider().overlay(AppTheme.border)
            settingsRow(
                symbol: "lock.shield.fill",
                title: "No account required",
                subtitle: "There is no sign-in, no ads, and no third-party tracking."
            )
        }
    }

    private var supportSection: some View {
        settingsCard(title: "Support") {
            Button {
                requestReview()
            } label: {
                settingsRow(symbol: "star.fill", title: "Rate the app", subtitle: "Leave a review if Document Expiry Tracker helps you stay ahead.")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                sendFeedback()
            } label: {
                settingsRow(symbol: "envelope.fill", title: "Share feedback", subtitle: "Send thoughts or support questions by email.")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                showingAbout = true
            } label: {
                settingsRow(symbol: "info.circle.fill", title: "About", subtitle: "Learn more about the app and its premium features.")
            }
            .buttonStyle(.plain)
        }
    }

    #if DEBUG
    private var developerSection: some View {
        settingsCard(title: "Developer") {
            Button {
                purchaseManager.persist(!purchaseManager.isProUnlocked)
            } label: {
                HStack(spacing: 12) {
                    leadingIcon(symbol: "checkmark.seal.fill")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pro Override")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(purchaseManager.isProUnlocked ? "Pro is active. Tap to deactivate." : "Pro is inactive. Tap to activate.")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    Text(purchaseManager.isProUnlocked ? "ON" : "OFF")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(purchaseManager.isProUnlocked ? AppTheme.success : AppTheme.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(purchaseManager.isProUnlocked ? AppTheme.success.opacity(0.15) : AppTheme.fillMuted)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_pro_override")

            Divider().overlay(AppTheme.border)

            Button {
                generateSampleData()
            } label: {
                settingsRow(
                    symbol: "wand.and.stars",
                    title: "Generate Sample Data",
                    subtitle: "Adds 14 realistic sample items including subscriptions and warranties."
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                showingResetConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.danger)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.danger.opacity(0.12))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reset All Data")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.danger)
                        Text("Deletes all items. Cannot be undone.")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    private func generateSampleData() {
        let cal = Calendar.current
        let now = Date.now
        func date(_ days: Int) -> Date { cal.date(byAdding: .day, value: days, to: now)! }

        let samples: [TrackedItem] = [
            TrackedItem(title: "Passport", category: .document, provider: "Ministry of Interior",
                        dueDate: date(730), notesText: "Biometric passport", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Driver's License", category: .document, provider: "DMV",
                        dueDate: date(365), notesText: "Category B", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Health Insurance Card", category: .document, provider: "National Health",
                        dueDate: date(180), recurringInterval: .yearly, notesText: "Renew at the clinic", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays, .oneDay]),
            TrackedItem(title: "Work Permit", category: .document, provider: "Ministry of Labor",
                        dueDate: date(90), recurringInterval: .yearly, notesText: "Renew 30 days before expiry",
                        reminders: [.thirtyDays, .sevenDays, .threeDays]),
            TrackedItem(title: "Vehicle Registration", category: .document, provider: "DMV",
                        dueDate: date(-15), recurringInterval: .yearly, notesText: "EXPIRED – renew ASAP",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Netflix", category: .subscription, provider: "Netflix Inc.",
                        dueDate: date(12), recurringInterval: .monthly, amount: 15.99, currencyCode: "USD",
                        reminders: [.threeDays]),
            TrackedItem(title: "Spotify Premium", category: .subscription, provider: "Spotify",
                        dueDate: date(5), recurringInterval: .monthly, amount: 9.99, currencyCode: "USD",
                        reminders: [.threeDays, .oneDay]),
            TrackedItem(title: "iCloud+ 50GB", category: .subscription, provider: "Apple",
                        dueDate: date(20), recurringInterval: .monthly, amount: 0.99, currencyCode: "USD",
                        reminders: [.oneDay]),
            TrackedItem(title: "iPhone 15 Pro Warranty", category: .warranty, provider: "Apple",
                        dueDate: date(300), notesText: "AppleCare+",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "MacBook Pro Warranty", category: .warranty, provider: "Apple",
                        dueDate: date(60), notesText: "Serial: C02XG...",
                        reminders: [.thirtyDays, .sevenDays, .oneDay]),
            TrackedItem(title: "Sony TV Warranty", category: .warranty, provider: "Sony",
                        dueDate: date(500), notesText: "Model: XR-65A80L",
                        reminders: [.thirtyDays]),
            TrackedItem(title: "Car Insurance", category: .insurance, provider: "Geico",
                        dueDate: date(240), recurringInterval: .yearly, amount: 320.00, currencyCode: "USD",
                        notesText: "Comprehensive + Collision",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Home Insurance", category: .insurance, provider: "State Farm",
                        dueDate: date(120), recurringInterval: .yearly, amount: 180.00, currencyCode: "USD",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Apartment Lease", category: .contract, provider: "Landlord",
                        dueDate: date(305), recurringInterval: .yearly, amount: 1650.00, currencyCode: "USD",
                        notesText: "Auto-renews unless canceled 30 days prior.",
                        reminders: [.thirtyDays, .sevenDays]),
        ]
        for item in samples { modelContext.insert(item) }
        statusMessage = "Generated \(samples.count) items."
    }
    #endif

    private var appLockSubtitle: String {
        if !purchaseManager.isProUnlocked {
            return "Protect sensitive items with Face ID or biometrics as part of Pro."
        }
        if appLockManager.isBiometricsAvailable {
            return "Require \(appLockManager.biometryTitle) when returning to the app."
        }
        return "Biometric authentication is not available on this device."
    }

    private func settingsCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textMuted)
                .padding(.horizontal, 4)
            VStack(spacing: 0) {
                content()
            }
            .appCardStyle(padding: 0, radius: 24)
        }
    }

    private func settingsRow(symbol: String, title: String, subtitle: String, value: String? = nil) -> some View {
        HStack(spacing: 12) {
            leadingIcon(symbol: symbol)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            if let value {
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    private func leadingIcon(symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 18))
            .foregroundStyle(AppTheme.textSecondary)
            .frame(width: 40, height: 40)
            .background(AppTheme.fillSoft)
            .clipShape(Circle())
    }

    private func updateAppLock(enabled: Bool) {
        if enabled && !purchaseManager.isProUnlocked {
            settings.isAppLockEnabled = false
            onUpgradeTapped(.appLock)
            return
        }

        guard enabled else {
            settings.isAppLockEnabled = false
            return
        }

        appLockManager.refreshAvailability()
        guard appLockManager.isBiometricsAvailable else {
            settings.isAppLockEnabled = false
            statusMessage = "Biometric authentication is not available on this device."
            return
        }

        settings.isAppLockEnabled = true
        statusMessage = "\(appLockManager.biometryTitle) lock is enabled."
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        statusMessage = "Thanks for considering a review."
    }

    private func sendFeedback() {
        guard let url = URL(string: "mailto:support@documentexpirytracker.app?subject=Document%20Expiry%20Tracker%20Feedback") else {
            return
        }
        openURL(url)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
