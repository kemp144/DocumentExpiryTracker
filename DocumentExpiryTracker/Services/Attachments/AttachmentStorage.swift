import Foundation
import UniformTypeIdentifiers

enum AttachmentStorageError: LocalizedError {
    case invalidImage
    case failedToAccessFile

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            "That image could not be imported."
        case .failedToAccessFile:
            "That file could not be accessed."
        }
    }
}

enum AttachmentStorage {
    static func importPhotoData(_ data: Data, suggestedName: String = "Photo") throws -> StoredAttachment {
        guard !data.isEmpty else { throw AttachmentStorageError.invalidImage }
        let attachmentID = UUID()
        let fileName = "\(attachmentID.uuidString).jpg"
        let url = try directoryURL().appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return StoredAttachment(
            id: attachmentID,
            fileName: fileName,
            originalName: suggestedName,
            kind: .image
        )
    }

    static func importFile(at sourceURL: URL) throws -> StoredAttachment {
        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: sourceURL)
        guard !data.isEmpty else { throw AttachmentStorageError.failedToAccessFile }

        let attachmentID = UUID()
        let ext = sourceURL.pathExtension.isEmpty ? "dat" : sourceURL.pathExtension.lowercased()
        let fileName = "\(attachmentID.uuidString).\(ext)"
        let destinationURL = try directoryURL().appendingPathComponent(fileName)
        try data.write(to: destinationURL, options: .atomic)

        return StoredAttachment(
            id: attachmentID,
            fileName: fileName,
            originalName: sourceURL.lastPathComponent,
            kind: kind(forExtension: ext)
        )
    }

    static func delete(_ attachment: StoredAttachment) {
        try? FileManager.default.removeItem(at: fileURL(for: attachment))
    }

    static func deleteAll(_ attachments: [StoredAttachment]) {
        attachments.forEach(delete)
    }

    static func fileURL(for attachment: StoredAttachment) -> URL {
        (try? directoryURL().appendingPathComponent(attachment.fileName)) ?? FileManager.default.temporaryDirectory
    }

    private static func directoryURL() throws -> URL {
        let baseURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let attachmentsURL = baseURL.appendingPathComponent("Attachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: attachmentsURL.path) {
            try FileManager.default.createDirectory(at: attachmentsURL, withIntermediateDirectories: true)
        }
        return attachmentsURL
    }

    private static func kind(forExtension fileExtension: String) -> AttachmentKind {
        if let type = UTType(filenameExtension: fileExtension) {
            if type.conforms(to: .image) {
                return .image
            }
            if type.conforms(to: .pdf) {
                return .pdf
            }
        }
        return .document
    }
}
