import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func refreshStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshStatus()
            return granted
        } catch {
            await refreshStatus()
            return false
        }
    }

    func removeNotifications(for item: TrackedItem) {
        let identifiers = ReminderOffset.allCases.map { "\(item.id.uuidString)-\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleNotifications(for item: TrackedItem) async {
        removeNotifications(for: item)
        guard item.isArchived == false else { return }
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        let calendar = Calendar.current
        let dueDay = calendar.startOfDay(for: ItemAnalytics.effectiveDueDate(for: item, calendar: calendar))

        for offset in item.reminders {
            guard let triggerDate = calendar.date(byAdding: .day, value: -offset.rawValue, to: dueDay),
                  triggerDate > .now
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = item.title
            if offset == .sameDay {
                content.body = "\(ItemAnalytics.actionLabel(for: item)) today in Document Expiry Tracker."
            } else {
                content.body = "\(ItemAnalytics.actionLabel(for: item)) in \(offset.rawValue) day\(offset.rawValue == 1 ? "" : "s") in Document Expiry Tracker."
            }
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(item.id.uuidString)-\(offset.rawValue)",
                content: content,
                trigger: trigger
            )

            do {
                try await add(request: request)
            } catch {
                continue
            }
        }
    }

    private func add(request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    var summaryTitle: String {
        switch authorizationStatus {
        case .authorized, .provisional: "Enabled"
        case .denied: "Off"
        case .notDetermined: "Not yet enabled"
        case .ephemeral: "Temporary"
        @unknown default: "Unknown"
        }
    }

    var summaryMessage: String {
        switch authorizationStatus {
        case .authorized, .provisional:
            "Reminders are active for your upcoming renewals."
        case .denied:
            "Notifications are disabled. You can turn them back on in Settings."
        case .notDetermined:
            "Enable notifications to get gentle reminders before important due dates."
        case .ephemeral:
            "Notifications are temporarily available."
        @unknown default:
            "Notification status could not be determined."
        }
    }
}
