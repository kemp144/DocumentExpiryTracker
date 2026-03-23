import EventKit
import Foundation

// MARK: - Calendar Service
// Provides EventKit-based calendar integration.
// Uses EKEventEditViewController for the best native UX when presenting from a view.
// Falls back to programmatic save when full access is available without needing the editor.

@MainActor
final class CalendarService: ObservableObject {

    // MARK: - Published state

    @Published private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined

    // MARK: - Internal

    let store = EKEventStore()

    /// Convenience accessor for views that need to pass the store to EKEventEditViewController.
    var eventStore: EKEventStore { store }

    // MARK: - Init

    init() {
        refreshStatus()
    }

    // MARK: - Authorization

    func refreshStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    /// Request full-access calendar permission (iOS 17+).
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            refreshStatus()
            return granted
        } catch {
            refreshStatus()
            return false
        }
    }

    // MARK: - Event building

    /// Build a pre-populated EKEvent for the given item.
    /// The caller may present EKEventEditViewController or save directly.
    func buildEvent(for item: TrackedItem) -> EKEvent {
        let event = EKEvent(eventStore: store)

        // Choose a clear, natural-language title
        event.title = eventTitle(for: item)

        // All-day event on the due date — most appropriate for expiry/renewal tracking
        let dueDate = ItemAnalytics.effectiveDueDate(for: item)
        event.isAllDay = true
        event.startDate = dueDate
        event.endDate = dueDate

        // Populate notes with useful context
        event.notes = eventNotes(for: item)

        // Use default calendar
        event.calendar = store.defaultCalendarForNewEvents

        // Add a reminder alarm one day before when possible
        if let alarm = EKAlarm(relativeOffset: -86400) as EKAlarm? {
            event.addAlarm(alarm)
        }

        return event
    }

    /// Save an event programmatically (requires .fullAccess status).
    /// Returns the event identifier on success.
    func saveEvent(for item: TrackedItem) throws -> String {
        guard authorizationStatus == .fullAccess else {
            throw CalendarError.accessDenied
        }
        let event = buildEvent(for: item)
        try store.save(event, span: .thisEvent)
        return event.eventIdentifier ?? ""
    }

    // MARK: - Event content helpers

    private func eventTitle(for item: TrackedItem) -> String {
        let verb = item.isRecurring ? "renews" : "expires"
        if item.provider.isEmpty {
            return "\(item.title) \(verb)"
        }
        // "Netflix renewal" / "Passport expires"
        if item.isRecurring {
            return "\(item.title) renewal"
        }
        return "\(item.title) expires"
    }

    private func eventNotes(for item: TrackedItem) -> String {
        var lines: [String] = []

        lines.append("Category: \(item.category.title)")

        if !item.provider.isEmpty {
            lines.append("Provider: \(item.provider)")
        }
        if !item.ownerName.isEmpty {
            lines.append("Owner: \(item.ownerName)")
        }
        if let amount = item.amount {
            let formatted = AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode)
            let suffix = item.isRecurring ? " / \(item.recurringInterval.title.lowercased())" : ""
            lines.append("Cost: \(formatted)\(suffix)")
        }

        lines.append("Status: \(ItemAnalytics.urgencyTitle(for: item))")

        if !item.notesText.isEmpty {
            lines.append("")
            lines.append("Notes: \(item.notesText)")
        }

        lines.append("")
        lines.append("Tracked in Document Expiry Tracker")
        return lines.joined(separator: "\n")
    }

    // MARK: - Error

    enum CalendarError: LocalizedError {
        case accessDenied
        case saveFailed(String)

        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Calendar access is required. Please allow access in Settings."
            case .saveFailed(let message):
                return "Could not save the calendar event: \(message)"
            }
        }
    }
}

// MARK: - SwiftUI View Representable for EKEventEditViewController

import SwiftUI
import EventKitUI

struct EventEditView: UIViewControllerRepresentable {
    let event: EKEvent
    let store: EKEventStore
    let onDone: (EKEventEditViewAction) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onDone: onDone)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.eventStore = store
        vc.event = event
        vc.editViewDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onDone: (EKEventEditViewAction) -> Void

        init(onDone: @escaping (EKEventEditViewAction) -> Void) {
            self.onDone = onDone
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            onDone(action)
        }
    }

}
