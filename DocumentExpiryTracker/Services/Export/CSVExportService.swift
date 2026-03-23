import Foundation

enum CSVExportService {

    // MARK: - Public API

    /// Build a CSV string for an array of items.
    static func buildCSV(items: [TrackedItem]) -> String {
        var rows: [String] = [headerRow]
        for item in items {
            rows.append(csvRow(for: item))
        }
        return rows.joined(separator: "\n")
    }

    /// Write the CSV to a temporary file and return its URL for sharing.
    /// The caller is responsible for cleaning up the file after the share sheet dismisses.
    static func temporaryFile(for items: [TrackedItem], filename: String? = nil) -> URL {
        let csv = buildCSV(items: items)
        let name = filename ?? defaultFilename()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? csv.data(using: .utf8)?.write(to: url)
        return url
    }

    // MARK: - Header

    private static let headerRow = [
        "Title",
        "Category",
        "Provider",
        "Status",
        "Due Date",
        "Is Recurring",
        "Recurrence",
        "Amount",
        "Currency",
        "Owner",
        "Reminder Count",
        "Reminders",
        "Notes",
        "Is Archived",
        "Created Date",
        "Updated Date"
    ].map(csvEscape).joined(separator: ",")

    // MARK: - Row builder

    private static func csvRow(for item: TrackedItem) -> String {
        let effectiveDue = ItemAnalytics.effectiveDueDate(for: item)
        let status = ItemAnalytics.status(for: item)

        let fields: [String] = [
            item.title,
            item.category.title,
            item.provider,
            status.title,
            iso8601Date(effectiveDue),
            item.isRecurring ? "Yes" : "No",
            item.isRecurring ? item.recurringInterval.title : "",
            item.amount.map { formatAmount($0) } ?? "",
            item.amount != nil ? item.currencyCode : "",
            item.ownerName,
            "\(item.reminders.count)",
            item.reminders.map(\.title).joined(separator: "; "),
            item.notesText,
            item.isArchived ? "Yes" : "No",
            iso8601Date(item.createdAt),
            iso8601Date(item.updatedAt)
        ]

        return fields.map(csvEscape).joined(separator: ",")
    }

    // MARK: - Formatting helpers

    /// RFC 4180 CSV cell escaping: wrap in quotes if the value contains a comma, quote, or newline.
    private static func csvEscape(_ value: String) -> String {
        let needsQuoting = value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r")
        guard needsQuoting else { return value }
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()

    private static func iso8601Date(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }

    private static func formatAmount(_ amount: Double) -> String {
        // Stable spreadsheet-friendly numeric value, 2 decimal places
        String(format: "%.2f", amount)
    }

    private static func defaultFilename() -> String {
        let date = isoFormatter.string(from: Date.now)
        return "expiry-tracker-export-\(date).csv"
    }
}
