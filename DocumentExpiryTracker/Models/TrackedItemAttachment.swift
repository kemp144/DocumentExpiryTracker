import Foundation
import SwiftData

@Model
final class TrackedItemAttachment {
    var id: UUID = UUID()
    var fileName: String = ""
    var originalName: String = ""
    var kindRaw: String = ""
    var createdAt: Date = Date.now
    
    @Attribute(.externalStorage)
    var fileData: Data?

    var item: TrackedItem?

    init(id: UUID = UUID(), fileName: String, originalName: String, kind: AttachmentKind, createdAt: Date = .now, fileData: Data? = nil) {
        self.id = id
        self.fileName = fileName
        self.originalName = originalName
        self.kindRaw = kind.rawValue
        self.createdAt = createdAt
        self.fileData = fileData
    }
    
    var kind: AttachmentKind {
        AttachmentKind(rawValue: kindRaw) ?? .document
    }
}
