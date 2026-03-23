import Foundation
import SwiftData

enum AppBootstrapper {
    @MainActor
    static func prepare(context: ModelContext, settings: AppSettings) {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("UITEST_SKIP_ONBOARDING") {
            settings.hasCompletedOnboarding = true
        }

        guard arguments.contains("UITEST_SEED_SAMPLE_ITEMS") else { return }

        let descriptor = FetchDescriptor<TrackedItem>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        let today = Calendar.current.startOfDay(for: .now)
        let samples = [
            TrackedItem(title: "Passport", category: .document, provider: "US Government", dueDate: Calendar.current.date(byAdding: .day, value: 45, to: today) ?? today, reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Netflix", category: .subscription, provider: "Netflix", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today, recurringInterval: .monthly, amount: 15.99, reminders: [.oneDay]),
            TrackedItem(title: "Car Insurance", category: .insurance, provider: "State Farm", dueDate: Calendar.current.date(byAdding: .day, value: 70, to: today) ?? today, recurringInterval: .yearly, amount: 1200, reminders: [.thirtyDays, .sevenDays]),
            TrackedItem(title: "Driver License", category: .document, provider: "DMV", dueDate: Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today, reminders: [.sevenDays]),
            TrackedItem(title: "Spotify Premium", category: .subscription, provider: "Spotify", dueDate: Calendar.current.date(byAdding: .day, value: 6, to: today) ?? today, recurringInterval: .monthly, amount: 10.99, reminders: [.oneDay])
        ]

        for item in samples {
            context.insert(item)
        }

        try? context.save()
    }
}
