import SwiftUI
import StoreKit
import UIKit
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TrackedItem]

    let onUpgradeTapped: () -> Void

    @State private var statusMessage: String?
    @State private var showingAbout = false
    @State private var showingResetConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Document Expiry Tracker")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                privacyHero
                notificationsSection
                privacySection
                proSection
                supportSection
                developerSection

                if let statusMessage {
                    Text(statusMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(spacing: 4) {
                    Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Made with care for your privacy")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .confirmationDialog("Reset All Data", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Delete All Items", role: .destructive) {
                for item in allItems {
                    modelContext.delete(item)
                }
                statusMessage = "All data deleted."
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(allItems.count) items. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Document Expiry Tracker is a local-first utility for tracking documents, subscriptions, warranties, contracts, insurance, and other important due dates. Your data stays on device, reminders are local, and there is no account required.")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineSpacing(3)
                            .padding(20)
                    }
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
                    Text("Privacy First")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("Your data, your device")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
            }
            Text("All your data is stored locally on your iPhone. Document Expiry Tracker does not require an account, upload your items, or share personal information.")
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.88))
                .lineSpacing(2)
        }
        .padding(22)
        .background(AppTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var notificationsSection: some View {
        settingsCard(title: "Notifications") {
            settingsRow(symbol: "bell.fill", title: "Notification Status", subtitle: notificationManager.summaryMessage, value: notificationManager.summaryTitle)
            Divider().overlay(AppTheme.border)
            settingsRow(symbol: "clock.badge", title: "Reminder Timing", subtitle: "Same day, 1 day, 3 days, 7 days, or 30 days before an item is due.")
        }
    }

    private var privacySection: some View {
        settingsCard(title: "Privacy") {
            settingsRow(symbol: "hand.raised.fill", title: "Data & Security", subtitle: "Everything stays on-device. No backend, login, or ads.")
            Divider().overlay(AppTheme.border)
            settingsRow(symbol: "circle.lefthalf.filled", title: "Appearance", subtitle: "Placeholder for future appearance settings.", value: "System")
        }
    }

    private var proSection: some View {
        settingsCard(title: "Pro Features") {
            Button {
                onUpgradeTapped()
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
                        HStack(spacing: 6) {
                            Text(purchaseManager.isProUnlocked ? "Document Expiry Tracker Pro" : "Upgrade to Pro")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            if !purchaseManager.isProUnlocked {
                                Text("PRO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.brandGradient)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(purchaseManager.isProUnlocked ? "Unlocked on this device." : "Unlock unlimited items, multiple reminders, insights, and all currencies.")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_upgrade")

            Divider().overlay(AppTheme.border)

            Button {
                Task {
                    let restored = await purchaseManager.restore()
                    statusMessage = restored ? "Purchases restored." : (purchaseManager.lastError ?? "Nothing was restored.")
                }
            } label: {
                settingsRow(symbol: "arrow.clockwise", title: "Restore Purchases", subtitle: "Re-check your lifetime Pro unlock.")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_restore")

        }
    }

    private var supportSection: some View {
        settingsCard(title: "Support") {
            Button {
                requestReview()
            } label: {
                settingsRow(symbol: "star.fill", title: "Rate App", subtitle: "Leave a review if Document Expiry Tracker helps you stay organized.")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                statusMessage = "Support email: support@documentexpirytracker.app"
            } label: {
                settingsRow(symbol: "envelope.fill", title: "Contact Support", subtitle: "support@documentexpirytracker.app")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.border)

            Button {
                showingAbout = true
            } label: {
                settingsRow(symbol: "info.circle.fill", title: "About", subtitle: "Learn more about the app and its privacy-first approach.")
            }
            .buttonStyle(.plain)
        }
    }

    private var developerSection: some View {
        settingsCard(title: "Developer") {
            Button {
                purchaseManager.persist(!purchaseManager.isProUnlocked)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(purchaseManager.isProUnlocked ? AppTheme.success : AppTheme.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.fillSoft)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pro Override")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(purchaseManager.isProUnlocked ? "Pro je aktivan. Tapni da deaktiviraj." : "Pro je neaktivan. Tapni da aktiviraš.")
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
                    subtitle: "Dodaje 14 realnih stavki: dokumenta, pretplate, garancije, osiguranja i ugovor."
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
                        Text("Briše sve stavke. Ne može se povratiti.")
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

        func date(_ daysFromNow: Int) -> Date {
            cal.date(byAdding: .day, value: daysFromNow, to: now)!
        }

        let samples: [TrackedItem] = [
            // Documents (5)
            TrackedItem(title: "Passport", category: .document, provider: "Ministry of Interior",
                        dueDate: date(730), recurringInterval: .none,
                        notesText: "Biometric passport", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Driver's License", category: .document, provider: "MUP",
                        dueDate: date(365), recurringInterval: .none,
                        notesText: "Category B", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Health Insurance Card", category: .document, provider: "RFZO",
                        dueDate: date(180), recurringInterval: .yearly,
                        notesText: "Obnoviti kod doktora", ownerName: "Robert Engel",
                        reminders: [.thirtyDays, .sevenDays, .oneDay]),
            TrackedItem(title: "Work Permit", category: .document, provider: "Ministry of Labor",
                        dueDate: date(90), recurringInterval: .yearly,
                        notesText: "Renew 30 days before expiry",
                        reminders: [.thirtyDays, .sevenDays, .threeDays]),
            TrackedItem(title: "Vehicle Registration", category: .document, provider: "MUP",
                        dueDate: date(-15), recurringInterval: .yearly,
                        notesText: "EXPIRED – renew ASAP",
                        reminders: [.thirtyDays, .sevenDays]),

            // Subscriptions (3)
            TrackedItem(title: "Netflix", category: .subscription, provider: "Netflix Inc.",
                        dueDate: date(12), recurringInterval: .monthly,
                        amount: 15.99, currencyCode: "USD",
                        reminders: [.threeDays]),
            TrackedItem(title: "Spotify Premium", category: .subscription, provider: "Spotify",
                        dueDate: date(5), recurringInterval: .monthly,
                        amount: 9.99, currencyCode: "USD",
                        reminders: [.threeDays, .oneDay]),
            TrackedItem(title: "iCloud+ 50GB", category: .subscription, provider: "Apple",
                        dueDate: date(20), recurringInterval: .monthly,
                        amount: 0.99, currencyCode: "USD",
                        reminders: [.oneDay]),

            // Warranties (3)
            TrackedItem(title: "iPhone 15 Pro Warranty", category: .warranty, provider: "Apple",
                        dueDate: date(300), recurringInterval: .none,
                        notesText: "AppleCare+",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "MacBook Pro Warranty", category: .warranty, provider: "Apple",
                        dueDate: date(60), recurringInterval: .none,
                        notesText: "Serial: C02XG...",
                        reminders: [.thirtyDays, .sevenDays, .oneDay]),
            TrackedItem(title: "Sony TV Warranty", category: .warranty, provider: "Sony",
                        dueDate: date(500), recurringInterval: .none,
                        notesText: "Model: XR-65A80L",
                        reminders: [.thirtyDays]),

            // Insurance (2)
            TrackedItem(title: "Car Insurance", category: .insurance, provider: "Generali",
                        dueDate: date(240), recurringInterval: .yearly,
                        amount: 320.00, currencyCode: "EUR",
                        notesText: "Kasko + obavezno",
                        reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Home Insurance", category: .insurance, provider: "DDOR",
                        dueDate: date(120), recurringInterval: .yearly,
                        amount: 180.00, currencyCode: "EUR",
                        reminders: [.thirtyDays, .sevenDays]),

            // Contract (1)
            TrackedItem(title: "Apartment Lease", category: .contract, provider: "Landlord – Petar Petrović",
                        dueDate: date(305), recurringInterval: .yearly,
                        amount: 650.00, currencyCode: "EUR",
                        notesText: "Automatski se produžava ako se ne otkaže 30 dana pre isteka.",
                        reminders: [.thirtyDays, .sevenDays]),
        ]

        for item in samples {
            modelContext.insert(item)
        }
        statusMessage = "Generisano \(samples.count) stavki."
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
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 40, height: 40)
                .background(AppTheme.fillSoft)
                .clipShape(Circle())

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

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        statusMessage = "Thanks for considering a review."
    }
}
