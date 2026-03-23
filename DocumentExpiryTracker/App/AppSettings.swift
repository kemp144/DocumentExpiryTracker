import Foundation

@MainActor
final class AppSettings: ObservableObject {
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let preferredAppearance = "preferredAppearance"
    }

    private let defaults: UserDefaults
    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var preferredAppearance: String {
        didSet { defaults.set(preferredAppearance, forKey: Keys.preferredAppearance) }
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
    }
}
