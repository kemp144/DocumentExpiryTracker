import Foundation

struct ICloudSyncStatus {
    let title: String
    let message: String
    let isActive: Bool
}

enum ICloudSyncStatusService {
    static func status(isProUnlocked: Bool) -> ICloudSyncStatus {
        guard isProUnlocked else {
            return ICloudSyncStatus(
                title: "Pro required",
                message: "Upgrade to Pro to enable iCloud backup and item sync across your devices.",
                isActive: false
            )
        }

        let hasICloudAccount = FileManager.default.ubiquityIdentityToken != nil
        guard hasICloudAccount else {
            return ICloudSyncStatus(
                title: "iCloud unavailable",
                message: "Sign in to iCloud in iPhone Settings to enable item backup and sync.",
                isActive: false
            )
        }

        return ICloudSyncStatus(
            title: "Active",
            message: "Your item data is backed up and syncing across devices. Attached files remain local for now.",
            isActive: true
        )
    }
}
