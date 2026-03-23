import Foundation
import LocalAuthentication

@MainActor
final class AppLockManager: ObservableObject {
    @Published private(set) var isBiometricsAvailable = false
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var requiresUnlock = false
    @Published var lastError: String?

    func refreshAvailability() {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometryType = context.biometryType
        isBiometricsAvailable = canEvaluate
        if !canEvaluate, let error {
            lastError = error.localizedDescription
        }
    }

    func sceneDidBecomeActive(isEnabled: Bool, isProUnlocked: Bool, hasCompletedOnboarding: Bool) {
        guard hasCompletedOnboarding, isEnabled, isProUnlocked, isBiometricsAvailable else {
            requiresUnlock = false
            return
        }
        requiresUnlock = true
    }

    func unlock() async -> Bool {
        guard isBiometricsAvailable else {
            requiresUnlock = false
            return true
        }

        let context = LAContext()
        context.localizedCancelTitle = "Not now"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Document Expiry Tracker"
            )
            if success {
                requiresUnlock = false
            }
            return success
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    var biometryTitle: String {
        switch biometryType {
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        default:
            "Biometric Lock"
        }
    }
}
