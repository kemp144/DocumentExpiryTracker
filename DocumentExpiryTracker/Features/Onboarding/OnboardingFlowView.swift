import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var stepIndex = 0

    private let steps: [(symbol: String, title: String, message: String, gradient: [Color])] = [
        ("calendar", "Track What Matters", "Keep passports, subscriptions, warranties, contracts, insurance, and other due dates in one calm place.", [AppTheme.primary, AppTheme.purple]),
        ("bell.badge.fill", "Stay Ahead of Renewals", "Get timely reminders before something expires, renews, or becomes overdue.", [AppTheme.warning, Color(hex: "FF6B00")]),
        ("shield.fill", "Private, Local, and Simple", "Your data stays on your device so you can stay organized without giving up privacy.", [Color(hex: "34C759"), AppTheme.success])
    ]

    private var isNotificationStep: Bool {
        stepIndex == steps.count
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if !isNotificationStep {
                        Button("Skip") {
                            settings.hasCompletedOnboarding = true
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .accessibilityIdentifier("onboarding_skip")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Spacer()

                if isNotificationStep {
                    notificationPermissionStep
                } else {
                    let step = steps[stepIndex]

                    VStack(spacing: 28) {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(LinearGradient(colors: step.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 96, height: 96)
                            .overlay {
                                Image(systemName: step.symbol)
                                    .font(.system(size: 42, weight: .regular))
                                    .foregroundStyle(Color.white)
                            }

                        VStack(spacing: 12) {
                            Text(step.title)
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(step.message)
                                .font(.system(size: 17))
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<(steps.count + 1), id: \.self) { index in
                        Capsule()
                            .fill(index == stepIndex ? AppTheme.primary : AppTheme.fillMuted)
                            .frame(width: index == stepIndex ? 28 : 8, height: 8)
                    }
                }
                .padding(.bottom, 28)

                if isNotificationStep {
                    VStack(spacing: 12) {
                        Button("Enable Notifications") {
                            Task {
                                _ = await notificationManager.requestAuthorization()
                                settings.hasCompletedOnboarding = true
                            }
                        }
                        .buttonStyle(AppFilledButtonStyle(isLarge: true))
                        .accessibilityIdentifier("onboarding_enable_notifications")

                        Button("Maybe Later") {
                            settings.hasCompletedOnboarding = true
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .accessibilityIdentifier("onboarding_maybe_later")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                } else {
                    Button(stepIndex == steps.count - 1 ? "Get Started" : "Continue") {
                        stepIndex += 1
                    }
                    .buttonStyle(AppFilledButtonStyle(isLarge: true))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .accessibilityIdentifier("onboarding_continue")
                }
            }
        }
    }

    private var notificationPermissionStep: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.brandGradient)
                .frame(width: 96, height: 96)
                .overlay {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.white)
                }

            VStack(spacing: 12) {
                Text("Enable Notifications")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Get reminded before renewals, subscriptions, and important due dates so nothing slips past you.")
                    .font(.system(size: 17))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(alignment: .leading, spacing: 18) {
                permissionRow(title: "Timely reminders", message: "Get notified before something expires or renews.")
                permissionRow(title: "Flexible timing", message: "Choose the reminder schedule that fits how you plan ahead.")
                permissionRow(title: "Less mental load", message: "Keep important dates out of your head and safely tracked.")
            }
            .padding(20)
            .background(AppTheme.elevated)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 24)
        }
    }

    private func permissionRow(title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color(hex: "34C759"))
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}
