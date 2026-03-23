import Foundation

enum PremiumFeature: String, CaseIterable, Identifiable {
    case unlimitedItems
    case multipleReminders
    case widgets
    case cloudSync
    case attachments
    case appLock
    case advancedInsights
    case allCurrencies
    case csvExport
    case pdfExport
    case calendarIntegration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unlimitedItems: "Unlimited items"
        case .multipleReminders: "Multiple reminders"
        case .widgets: "Widgets"
        case .cloudSync: "iCloud backup & sync"
        case .attachments: "Attachments"
        case .appLock: "Face ID lock"
        case .advancedInsights: "Advanced insights"
        case .allCurrencies: "All currencies"
        case .csvExport: "CSV export"
        case .pdfExport: "PDF export"
        case .calendarIntegration: "Calendar integration"
        }
    }

    var message: String {
        switch self {
        case .unlimitedItems:
            "Protect everything important without running into the free item cap."
        case .multipleReminders:
            "Add more than one reminder so renewals never sneak up on you."
        case .widgets:
            "See your next due item and renewal summary from the Home Screen."
        case .cloudSync:
            "Keep your tracked items backed up and synced across devices with iCloud."
        case .attachments:
            "Attach local photos, scans, and PDFs to the items that matter most."
        case .appLock:
            "Add a private lock screen for sensitive documents and contracts."
        case .advancedInsights:
            "Understand recurring costs, renewal load, and what needs attention next."
        case .allCurrencies:
            "Track costs in the currency that matches your subscriptions and contracts."
        case .csvExport:
            "Export renewals and tracked items as CSV for spreadsheets and backups."
        case .pdfExport:
            "Generate clean PDF summaries for documents, warranties, and contracts."
        case .calendarIntegration:
            "Send renewals and expiration dates directly to Apple Calendar."
        }
    }

    var symbolName: String {
        switch self {
        case .unlimitedItems: "square.stack.3d.up.fill"
        case .multipleReminders: "bell.badge.fill"
        case .widgets: "rectangle.grid.2x2.fill"
        case .cloudSync: "icloud.fill"
        case .attachments: "paperclip"
        case .appLock: "faceid"
        case .advancedInsights: "chart.bar.xaxis"
        case .allCurrencies: "creditcard.fill"
        case .csvExport: "tablecells"
        case .pdfExport: "doc.richtext"
        case .calendarIntegration: "calendar.badge.plus"
        }
    }
}

enum PaywallContext: String, Identifiable {
    case general
    case softUpgrade
    case itemLimit
    case multipleReminders
    case widgets
    case cloudSync
    case attachments
    case appLock
    case insights
    case currencies
    case csvExport
    case pdfExport
    case calendarIntegration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            "Unlock Pro"
        case .softUpgrade:
            "Protect Everything Important"
        case .itemLimit:
            "Unlock Unlimited Tracking"
        case .multipleReminders:
            "Unlock More Reminder Times"
        case .widgets:
            "Unlock Home Screen Widgets"
        case .cloudSync:
            "Unlock Backup & Sync"
        case .attachments:
            "Unlock Attachments"
        case .appLock:
            "Unlock Face ID Lock"
        case .insights:
            "Unlock Advanced Insights"
        case .currencies:
            "Unlock All Currencies"
        case .csvExport:
            "Unlock CSV Export"
        case .pdfExport:
            "Unlock PDF Export"
        case .calendarIntegration:
            "Unlock Calendar Integration"
        }
    }

    var message: String {
        switch self {
        case .general:
            "Document Expiry Tracker Pro adds premium protection for renewals, subscriptions, warranties, and everything else you need to stay ahead of."
        case .softUpgrade:
            "You have the basics set up. Pro adds widgets, attachments, multiple reminders, and more room to track every renewal in one place."
        case .itemLimit:
            "Free includes up to 5 items. Pro unlocks unlimited tracking for documents, subscriptions, warranties, contracts, and more."
        case .multipleReminders:
            "Free includes one reminder per item. Pro lets you stack gentle reminder times before important due dates."
        case .widgets:
            "See your next due item, due soon count, and recurring summary from your Home Screen."
        case .cloudSync:
            "Keep item data backed up with iCloud while keeping the app privacy-conscious. Attached files remain local."
        case .attachments:
            "Keep scans, photos, and PDFs attached to the exact renewal or document they belong to (stored locally on this device)."
        case .appLock:
            "Protect sensitive items behind Face ID or biometrics without adding friction to the rest of the app."
        case .insights:
            "Go beyond the basics with recurring cost analysis, category breakdowns, and a clearer view of what is due next."
        case .currencies:
            "Track recurring costs in the currency that fits the service, contract, or policy you are managing."
        case .csvExport:
            "Export your renewals and tracked items to CSV. Useful for insurance, warranties, contracts, and subscriptions."
        case .pdfExport:
            "Create shareable PDF summaries for documents, warranties, and contracts. Keep clean records of the things you track."
        case .calendarIntegration:
            "Send renewals and expiration dates to Apple Calendar so important due dates appear alongside the rest of your schedule."
        }
    }

    var ctaTitle: String {
        switch self {
        case .softUpgrade:
            "Unlock Premium Protection"
        default:
            "Unlock Pro"
        }
    }

    var highlightedFeatures: [PremiumFeature] {
        switch self {
        case .itemLimit:
            [.unlimitedItems, .multipleReminders, .widgets, .advancedInsights]
        case .multipleReminders:
            [.multipleReminders, .unlimitedItems, .widgets, .advancedInsights]
        case .widgets:
            [.widgets, .unlimitedItems, .multipleReminders, .advancedInsights]
        case .cloudSync:
            [.cloudSync, .widgets, .attachments, .appLock]
        case .attachments:
            [.attachments, .cloudSync, .appLock, .unlimitedItems]
        case .appLock:
            [.appLock, .attachments, .cloudSync, .advancedInsights]
        case .insights:
            [.advancedInsights, .widgets, .multipleReminders, .unlimitedItems]
        case .currencies:
            [.allCurrencies, .advancedInsights, .unlimitedItems, .multipleReminders]
        case .csvExport:
            [.csvExport, .pdfExport, .calendarIntegration, .advancedInsights]
        case .pdfExport:
            [.pdfExport, .csvExport, .calendarIntegration, .attachments]
        case .calendarIntegration:
            [.calendarIntegration, .pdfExport, .csvExport, .multipleReminders]
        case .softUpgrade, .general:
            [.unlimitedItems, .multipleReminders, .widgets, .cloudSync, .attachments, .appLock, .csvExport, .pdfExport, .calendarIntegration, .advancedInsights, .allCurrencies]
        }
    }
}

enum FeatureGate {
    static let freeItemLimit = 5
    static let freeReminderLimit = 1

    static func canAddItem(existingItemCount: Int, isPro: Bool) -> Bool {
        isPro || existingItemCount < freeItemLimit
    }

    static func canUseReminderCount(_ count: Int, isPro: Bool) -> Bool {
        isPro || count <= freeReminderLimit
    }

    static func canUse(_ feature: PremiumFeature, isPro: Bool) -> Bool {
        isPro
    }

    static func availableCurrencies(isPro: Bool, locale: Locale = .current) -> [String] {
        let localeCurrency = locale.currency?.identifier ?? "USD"
        let all = ["USD", "EUR", "GBP", "CHF", "CAD", "AUD", "JPY"]
        return isPro ? all : [localeCurrency]
    }
}
