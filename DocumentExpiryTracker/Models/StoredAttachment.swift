import Foundation

enum AttachmentKind: String, Codable, CaseIterable, Identifiable {
    case image
    case pdf
    case document

    var id: String { rawValue }

    var title: String {
        switch self {
        case .image: "Image"
        case .pdf: "PDF"
        case .document: "Document"
        }
    }

    var symbolName: String {
        switch self {
        case .image: "photo.fill"
        case .pdf: "doc.richtext.fill"
        case .document: "doc.fill"
        }
    }
}

struct StoredAttachment: Codable, Hashable, Identifiable {
    let id: UUID
    let fileName: String
    let originalName: String
    let kindRaw: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        fileName: String,
        originalName: String,
        kind: AttachmentKind,
        createdAt: Date = .now
    ) {
        self.id = id
        self.fileName = fileName
        self.originalName = originalName
        self.kindRaw = kind.rawValue
        self.createdAt = createdAt
    }

    var kind: AttachmentKind {
        AttachmentKind(rawValue: kindRaw) ?? .document
    }
}
