import QuickLook
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
    @State private var shareItems: [Any] = []
    @State private var showingShareSheet = false
    @State private var previewDocument: PreviewDocument?

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
                    Text("Privacy-first tracking for renewals, subscriptions, warranties, and important due dates")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 16)

                privacyHero
                notificationsSection
                preferencesSection
                productivitySection
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
                        .padding(.horizontal, 16)
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

                        Text("Pro unlocks extra protection like widgets, local attachments, Face ID lock, advanced insights, and room to track everything important in one place.")
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
        .sheet(item: $previewDocument) { document in
            AttachmentPreviewController(url: document.url)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
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
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white)
                }

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Private by default")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("Your tracking stays local-first")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                VStack(alignment: .leading, spacing: 5) {
                    bulletPoint("Stored securely on your device")
                    bulletPoint("Local reminders only")
                    bulletPoint("No account or sign-in required")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
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
            Button {
                openAppSettings()
            } label: {
                settingsRow(
                    symbol: "bell.fill",
                    title: "Status",
                    subtitle: notificationManager.summaryMessage,
                    value: notificationManager.summaryTitle
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    private var preferencesSection: some View {
        settingsCard(title: "Preferences") {
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
                if purchaseManager.isProUnlocked {
                    Picker("Currency", selection: $settings.defaultCurrency) {
                        ForEach(FeatureGate.availableCurrencies(isPro: true), id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.primary)
                } else {
                    Button {
                        onUpgradeTapped(.currencies)
                    } label: {
                        HStack(spacing: 4) {
                            Text(settings.defaultCurrency)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    }
                    .buttonStyle(.plain)
                }
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
        .padding(.horizontal, 16)
    }

    private var productivitySection: some View {
        settingsCard(title: "Productivity") {
            Button {
                if purchaseManager.isProUnlocked {
                    exportPDF(items: allItems)
                } else {
                    onUpgradeTapped(.pdfExport)
                }
            } label: {
                settingsRow(
                    symbol: "doc.richtext",
                    title: "PDF Export",
                    subtitle: "Generate a clean PDF summary of all tracked items.",
                    value: purchaseManager.isProUnlocked ? "Export" : "Pro"
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                if purchaseManager.isProUnlocked {
                    exportCSV(items: allItems)
                } else {
                    onUpgradeTapped(.csvExport)
                }
            } label: {
                settingsRow(
                    symbol: "tablecells",
                    title: "CSV Export",
                    subtitle: "Export your records in spreadsheet format.",
                    value: purchaseManager.isProUnlocked ? "Export" : "Pro"
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)
            
            Button {
                if !purchaseManager.isProUnlocked {
                    onUpgradeTapped(.calendarIntegration)
                }
            } label: {
                settingsRow(
                    symbol: "calendar.badge.plus",
                    title: "Add to Calendar",
                    subtitle: purchaseManager.isProUnlocked
                        ? "Available on any item's detail screen — tap to add a renewal to Apple Calendar."
                        : "Add renewals and due dates directly to Apple Calendar.",
                    value: purchaseManager.isProUnlocked ? "Ready" : "Pro"
                )
            }
            .buttonStyle(.plain)
            .disabled(purchaseManager.isProUnlocked)
        }
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
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

    private func exportCSV(items: [TrackedItem]) {
        guard purchaseManager.isProUnlocked else {
            onUpgradeTapped(.csvExport)
            return
        }
        let url = CSVExportService.temporaryFile(for: items)
        shareItems = [url]
        showingShareSheet = true
    }

    private func exportPDF(items: [TrackedItem]) {
        guard purchaseManager.isProUnlocked else {
            onUpgradeTapped(.pdfExport)
            return
        }
        let url = PDFExportService.allItemsFile(items: items)
        let document = PreviewDocument(url: url)
        self.previewDocument = document
    }
}

private struct PreviewDocument: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct AttachmentPreviewController: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {}

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
