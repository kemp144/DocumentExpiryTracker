import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    let onUnlocked: (() -> Void)?

    @State private var isProcessing = false
    @State private var statusMessage: String?

    init(onUnlocked: (() -> Void)? = nil) {
        self.onUnlocked = onUnlocked
    }

    private let features: [(symbol: String, title: String, message: String)] = [
        ("chart.bar.xaxis", "Detailed Insights", "Track recurring costs, due counts, and category breakdowns."),
        ("bell.badge.fill", "Unlimited Reminders", "Add multiple reminder times to every important item."),
        ("creditcard.fill", "All Currencies", "Track spending in the currency that fits your life."),
        ("sparkles", "Premium Utility", "Support an indie app that stays privacy-first and ad-free.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(AppTheme.brandGradient)
                            .frame(width: 88, height: 88)
                            .overlay {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(Color.white)
                            }

                        VStack(spacing: 10) {
                            Text("Unlock Pro")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Color.white)

                            Text("Document Expiry Tracker Pro gives you unlimited items, multiple reminders, full insights, and all currencies in one calm, premium unlock.")
                                .font(.system(size: 17))
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                    }
                    .padding(.top, 20)

                    VStack(spacing: 18) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: 14) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [AppTheme.primary.opacity(0.18), AppTheme.purple.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 48, height: 48)
                                    .overlay {
                                        Image(systemName: feature.symbol)
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(AppTheme.primary)
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(feature.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(feature.message)
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineSpacing(2)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppTheme.success)
                            }
                        }
                    }
                    .appCardStyle(padding: 22, radius: 24)

                    VStack(spacing: 14) {
                        Text("One-time unlock")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(purchaseManager.priceLabel)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(Color.white)

                        Text("Pay once, keep Pro forever")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)

                        Divider().overlay(AppTheme.border)

                        Text("No subscription. No account. Just a permanent upgrade.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.86))
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "161618"), Color(hex: "26262A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button(isProcessing ? "Working..." : "Unlock Pro for \(purchaseManager.priceLabel)") {
                        Task { await performPurchase() }
                    }
                    .buttonStyle(AppFilledButtonStyle(isLarge: true))
                    .disabled(isProcessing)
                    .accessibilityIdentifier("paywall_unlock")

                    HStack(spacing: 18) {
                        Button("Restore Purchases") {
                            Task { await performRestore() }
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .accessibilityIdentifier("paywall_restore")

                        Text("•")
                            .foregroundStyle(AppTheme.textMuted)

                        Button("Close") { dismiss() }
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Text("Your purchase supports independent development and keeps Document Expiry Tracker private, local-first, and ad-free.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.fillSoft)
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("paywall_close")
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private func performPurchase() async {
        isProcessing = true
        defer { isProcessing = false }
        let success = await purchaseManager.purchase()
        if success {
            onUnlocked?()
            dismiss()
        } else {
            statusMessage = purchaseManager.lastError ?? "Unable to complete the purchase right now."
        }
    }

    private func performRestore() async {
        isProcessing = true
        defer { isProcessing = false }
        let success = await purchaseManager.restore()
        if success {
            onUnlocked?()
            dismiss()
        } else {
            statusMessage = purchaseManager.lastError ?? "Nothing was restored."
        }
    }
}
