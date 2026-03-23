import SwiftUI
import SwiftData

@main
struct DocumentExpiryTrackerApp: App {
    @StateObject private var settings: AppSettings
    @StateObject private var purchaseManager: PurchaseManager
    @StateObject private var notificationManager: NotificationManager

    private let modelContainer: ModelContainer

    init() {
        let settings = AppSettings()
        let purchaseManager = PurchaseManager()
        let notificationManager = NotificationManager()
        _settings = StateObject(wrappedValue: settings)
        _purchaseManager = StateObject(wrappedValue: purchaseManager)
        _notificationManager = StateObject(wrappedValue: notificationManager)

        do {
            let schema = Schema([TrackedItem.self])
            let arguments = ProcessInfo.processInfo.arguments
            let configuration: ModelConfiguration
            if arguments.contains("UITEST_IN_MEMORY_STORE") {
                configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            } else {
                configuration = ModelConfiguration(schema: schema)
            }
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
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
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
