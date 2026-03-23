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
    static func importPhotoData(_ data: Data, suggestedName: String = "Photo") throws -> TrackedItemAttachment {
        guard !data.isEmpty else { throw AttachmentStorageError.invalidImage }
        let attachmentID = UUID()
        let fileName = "\(attachmentID.uuidString).jpg"
        
        let attachment = TrackedItemAttachment(
            id: attachmentID,
            fileName: fileName,
            originalName: suggestedName,
            kind: .image,
            fileData: data
        )
        _ = try writeToLocalCache(attachment: attachment)
        return attachment
    }

    static func importFile(at sourceURL: URL) throws -> TrackedItemAttachment {
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
        
        let attachment = TrackedItemAttachment(
            id: attachmentID,
            fileName: fileName,
            originalName: sourceURL.lastPathComponent,
            kind: kind(forExtension: ext),
            fileData: data
        )
        _ = try writeToLocalCache(attachment: attachment)
        return attachment
    }

    static func fileURL(for attachment: TrackedItemAttachment) -> URL {
        let url = localURL(for: attachment)
        if !FileManager.default.fileExists(atPath: url.path) {
            if let data = attachment.fileData {
                try? data.write(to: url, options: [.atomic])
            }
        }
        return url
    }

    static func deleteLocalCache(for attachment: TrackedItemAttachment) {
        try? FileManager.default.removeItem(at: localURL(for: attachment))
    }

    static func deleteAllLocalCaches(_ attachments: [TrackedItemAttachment]) {
        attachments.forEach(deleteLocalCache)
    }

    private static func localURL(for attachment: TrackedItemAttachment) -> URL {
        if let dir = try? directoryURL() {
            return dir.appendingPathComponent(attachment.fileName)
        }
        return FileManager.default.temporaryDirectory.appendingPathComponent(attachment.fileName)
    }

    @discardableResult
    private static func writeToLocalCache(attachment: TrackedItemAttachment) throws -> URL {
        let url = localURL(for: attachment)
        if !FileManager.default.fileExists(atPath: url.path) {
            if let data = attachment.fileData {
                try data.write(to: url, options: [.atomic])
            } else {
                throw AttachmentStorageError.failedToAccessFile
            }
        }
        return url
    }

    // For migration
    static func legacyFileURL(for fileName: String) -> URL? {
        guard let baseURL = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return nil }
        let attachmentsURL = baseURL.appendingPathComponent("Attachments", isDirectory: true)
        return attachmentsURL.appendingPathComponent(fileName)
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
