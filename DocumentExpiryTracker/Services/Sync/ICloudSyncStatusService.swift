import Foundation

struct ICloudSyncStatus {
    let title: String
    let message: String
    let isAvailableForThisBuild: Bool
}

enum ICloudSyncStatusService {
    static func status(isProUnlocked: Bool) -> ICloudSyncStatus {
        guard isProUnlocked else {
            return ICloudSyncStatus(
                title: "Pro required",
                message: "Upgrade to Pro to prepare for backup and syncing across your devices.",
                isAvailableForThisBuild: false
            )
        }

        let hasICloudAccount = FileManager.default.ubiquityIdentityToken != nil
        if hasICloudAccount {
            return ICloudSyncStatus(
                title: "iCloud available",
                message: "This build is still storing data locally. Native CloudKit syncing can be enabled once an iCloud container is connected for release.",
                isAvailableForThisBuild: false
            )
        }

        return ICloudSyncStatus(
            title: "iCloud unavailable",
            message: "Sign in to iCloud on this device to prepare for future backup and sync support. Your data stays local for now.",
            isAvailableForThisBuild: false
        )
    }
}
