import Foundation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

@MainActor
final class AppSettings: ObservableObject {
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let preferredAppearance = "preferredAppearance"
        static let hasSeenSoftUpgradePrompt = "hasSeenSoftUpgradePrompt"
        static let shouldShowSoftUpgradePrompt = "shouldShowSoftUpgradePrompt"
        static let isAppLockEnabled = "isAppLockEnabled"
        static let defaultCurrency = "defaultCurrency"
    }

    private let defaults: UserDefaults
    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var preferredAppearance: String {
        didSet { defaults.set(preferredAppearance, forKey: Keys.preferredAppearance) }
    }

    @Published var hasSeenSoftUpgradePrompt: Bool {
        didSet { defaults.set(hasSeenSoftUpgradePrompt, forKey: Keys.hasSeenSoftUpgradePrompt) }
    }

    @Published var shouldShowSoftUpgradePrompt: Bool {
        didSet { defaults.set(shouldShowSoftUpgradePrompt, forKey: Keys.shouldShowSoftUpgradePrompt) }
    }

    @Published var isAppLockEnabled: Bool {
        didSet { defaults.set(isAppLockEnabled, forKey: Keys.isAppLockEnabled) }
    }
    
    @Published var defaultCurrency: String {
        didSet { defaults.set(defaultCurrency, forKey: Keys.defaultCurrency) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("UITEST_FORCE_ONBOARDING") {
            self.hasCompletedOnboarding = false
            defaults.set(false, forKey: Keys.hasCompletedOnboarding)
        } else {
            self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding) || arguments.contains("UITEST_SKIP_ONBOARDING")
        }
        self.preferredAppearance = defaults.string(forKey: Keys.preferredAppearance) ?? "system"
        self.hasSeenSoftUpgradePrompt = defaults.bool(forKey: Keys.hasSeenSoftUpgradePrompt)
        self.shouldShowSoftUpgradePrompt = defaults.bool(forKey: Keys.shouldShowSoftUpgradePrompt)
        self.isAppLockEnabled = defaults.bool(forKey: Keys.isAppLockEnabled)
        self.defaultCurrency = defaults.string(forKey: Keys.defaultCurrency) ?? Locale.current.currency?.identifier ?? "USD"
    }

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: preferredAppearance) ?? .system }
        set { preferredAppearance = newValue.rawValue }
    }

    func queueSoftUpgradePromptIfNeeded() {
        guard !hasSeenSoftUpgradePrompt else { return }
        shouldShowSoftUpgradePrompt = true
    }

    func dismissSoftUpgradePrompt(permanently: Bool) {
        shouldShowSoftUpgradePrompt = false
        if permanently {
            hasSeenSoftUpgradePrompt = true
        }
    }
}
