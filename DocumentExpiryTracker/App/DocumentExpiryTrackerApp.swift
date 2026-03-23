import SwiftUI
import SwiftData

@main
struct DocumentExpiryTrackerApp: App {
    @StateObject private var settings: AppSettings
    @StateObject private var purchaseManager: PurchaseManager
    @StateObject private var notificationManager: NotificationManager
    @StateObject private var appLockManager: AppLockManager

    private let modelContainer: ModelContainer

    init() {
        let settings = AppSettings()
        let purchaseManager = PurchaseManager()
        let notificationManager = NotificationManager()
        let appLockManager = AppLockManager()
        _settings = StateObject(wrappedValue: settings)
        _purchaseManager = StateObject(wrappedValue: purchaseManager)
        _notificationManager = StateObject(wrappedValue: notificationManager)
        _appLockManager = StateObject(wrappedValue: appLockManager)

        do {
            let schema = Schema([TrackedItem.self])
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("UITEST_IN_MEMORY_STORE") {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } else {
                // Attempt CloudKit-backed container first; fall back to local if CloudKit
                // is unavailable (e.g. simulator without a signed team, or missing container).
                do {
                    let configuration = ModelConfiguration(
                        schema: schema,
                        cloudKitDatabase: .private("iCloud.com.expiryvault.app")
                    )
                    modelContainer = try ModelContainer(for: schema, configurations: [configuration])
                } catch {
                    let configuration = ModelConfiguration(schema: schema)
                    modelContainer = try ModelContainer(for: schema, configurations: [configuration])
                }
            }
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(purchaseManager)
                .environmentObject(notificationManager)
                .environmentObject(appLockManager)
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(modelContainer)
    }

    private var preferredColorScheme: ColorScheme? {
        switch settings.appearanceMode {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
