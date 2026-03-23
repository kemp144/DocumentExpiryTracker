import Foundation
import UIKit

// MARK: - PDF Export Service
// Generates clean, light-background PDFs suitable for record-keeping.
// Uses UIGraphicsPDFRenderer (no dependencies beyond UIKit).

enum PDFExportService {

    // MARK: - Public API

    /// Build a PDF for a single item and write to a temporary file.
    static func singleItemFile(for item: TrackedItem) -> URL {
        let renderer = makePDFRenderer()
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            drawSingleItem(item, in: ctx.pdfContextBounds)
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(singleItemFilename(item))
        try? data.write(to: url)
        return url
    }

    /// Build a PDF summary of all items and write to a temporary file.
    static func allItemsFile(items: [TrackedItem], filename: String? = nil) -> URL {
        let renderer = makePDFRenderer()
        let data = renderer.pdfData { ctx in
            drawAllItemsReport(items: items, ctx: ctx)
        }
        let name = filename ?? defaultSummaryFilename()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? data.write(to: url)
        return url
    }

    // MARK: - Page setup

    private static let pageSize = CGSize(width: 612, height: 792) // US Letter
    private static let margin: CGFloat = 48
    private static var contentWidth: CGFloat { pageSize.width - margin * 2 }

    private static func makePDFRenderer() -> UIGraphicsPDFRenderer {
        let format = UIGraphicsPDFRendererFormat()
        let meta: [String: Any] = [
            kCGPDFContextTitle as String: "Expiry Tracker Export",
            kCGPDFContextAuthor as String: "Document Expiry Tracker"
        ]
        format.documentInfo = meta
        return UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
    }

    // MARK: - Single item PDF layout

    private static func drawSingleItem(_ item: TrackedItem, in bounds: CGRect) {
        var y: CGFloat = margin

        // ── Brand header ──────────────────────────────────────────────────────
        y = drawPageHeader(title: "Item Summary", date: Date.now, y: y)
        y += 24

        // ── Item title block ──────────────────────────────────────────────────
        let effectiveDue = ItemAnalytics.effectiveDueDate(for: item)
        let status = ItemAnalytics.status(for: item)

        y = drawSection(title: item.title, subtitle: item.category.title, y: y)
        y += 16

        // ── Detail rows ───────────────────────────────────────────────────────
        var rows: [(String, String)] = [
            (item.isRecurring ? "Next Renewal" : "Due Date", humanDate(effectiveDue)),
            ("Status", ItemAnalytics.urgencyTitle(for: item)),
            ("Category", item.category.title)
        ]

        if !item.provider.isEmpty {
            rows.append(("Provider", item.provider))
        }
        if item.isRecurring {
            rows.append(("Recurrence", item.recurringInterval.title))
        }
        if let amount = item.amount {
            let costLabel = AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode)
            let suffix = item.isRecurring ? " / \(item.recurringInterval.title.lowercased())" : ""
            rows.append(("Cost", costLabel + suffix))
        }
        if !item.ownerName.isEmpty {
            rows.append(("Owner", item.ownerName))
        }
        if !item.reminders.isEmpty {
            rows.append(("Reminders", item.reminders.map(\.title).joined(separator: ", ")))
        }
        rows.append(("Archived", item.isArchived ? "Yes" : "No"))
        rows.append(("Created", humanDate(item.createdAt)))
        rows.append(("Updated", humanDate(item.updatedAt)))

        y = drawDetailTable(rows: rows, y: y)
        y += 20

        // ── Status badge ───────────────────────────────────────────────────────
        y = drawStatusCallout(status: status, text: ItemAnalytics.countdownText(for: item), y: y)
        y += 20

        // ── Notes ──────────────────────────────────────────────────────────────
        if !item.notesText.isEmpty {
            y = drawNotesBlock(notes: item.notesText, y: y)
            y += 20
        }

        // ── Attachments list ───────────────────────────────────────────────────
        if !item.attachments.isEmpty {
            y = drawAttachmentsList(attachments: item.attachments, y: y)
        }

        // ── Footer ─────────────────────────────────────────────────────────────
        drawPageFooter(pageNumber: 1)
    }

    // MARK: - All items PDF layout

    private static func drawAllItemsReport(items: [TrackedItem], ctx: UIGraphicsPDFRendererContext) {
        // Title page
        ctx.beginPage()
        drawReportTitlePage(items: items)

        // Group items by category, then draw them
        let grouped = Dictionary(grouping: items) { $0.category }
        let orderedCategories = ItemCategory.allCases.filter { grouped[$0] != nil }

        var pageNumber = 2
        for category in orderedCategories {
            guard let categoryItems = grouped[category] else { continue }
            ctx.beginPage()
            var y: CGFloat = margin
            y = drawPageHeader(title: category.pluralTitle, date: Date.now, y: y)
            y += 8

            for item in categoryItems {
                let rowHeight = estimatedItemRowHeight(item)
                // If item won't fit on remaining page, begin a new page
                if y + rowHeight > pageSize.height - margin * 2 {
                    drawPageFooter(pageNumber: pageNumber)
                    pageNumber += 1
                    ctx.beginPage()
                    y = margin
                    y = drawPageHeader(title: category.pluralTitle + " (cont.)", date: Date.now, y: y)
                    y += 8
                }
                y = drawItemRow(item: item, y: y)
                y += 8
            }
            drawPageFooter(pageNumber: pageNumber)
            pageNumber += 1
        }
    }

    // MARK: - Title page

    private static func drawReportTitlePage(items: [TrackedItem]) {
        let centerX = pageSize.width / 2
        var y: CGFloat = pageSize.height * 0.28

        // App name
        draw(
            text: "Document Expiry Tracker",
            font: .systemFont(ofSize: 26, weight: .bold),
            color: textPrimary,
            at: CGPoint(x: centerX, y: y),
            width: contentWidth,
            alignment: .center
        )
        y += 36

        // Subtitle
        draw(
            text: "Item Export Summary",
            font: .systemFont(ofSize: 16, weight: .regular),
            color: textSecondary,
            at: CGPoint(x: centerX, y: y),
            width: contentWidth,
            alignment: .center
        )
        y += 16

        // Date
        draw(
            text: "Generated \(humanDate(Date.now))",
            font: .systemFont(ofSize: 13),
            color: textMuted,
            at: CGPoint(x: centerX, y: y),
            width: contentWidth,
            alignment: .center
        )
        y += 48

        // Divider
        drawHRule(y: y, color: borderColor)
        y += 24

        // Stats block
        let active = ItemAnalytics.activeItems(from: items)
        let expired = ItemAnalytics.expiredItems(from: items)
        let dueSoon = ItemAnalytics.dueSoonItems(from: items)
        let recurring = items.filter(\.isRecurring)

        let stats: [(String, String)] = [
            ("Total Items", "\(items.count)"),
            ("Active", "\(active.count)"),
            ("Due Soon", "\(dueSoon.count)"),
            ("Expired", "\(expired.count)"),
            ("Recurring", "\(recurring.count)")
        ]

        let statWidth: CGFloat = contentWidth / CGFloat(stats.count)
        for (index, stat) in stats.enumerated() {
            let x = margin + CGFloat(index) * statWidth + statWidth / 2
            draw(
                text: stat.1,
                font: .systemFont(ofSize: 22, weight: .bold),
                color: accentColor,
                at: CGPoint(x: x, y: y),
                width: statWidth - 8,
                alignment: .center
            )
            draw(
                text: stat.0,
                font: .systemFont(ofSize: 11),
                color: textSecondary,
                at: CGPoint(x: x, y: y + 28),
                width: statWidth - 8,
                alignment: .center
            )
        }
    }

    // MARK: - Item row (compact, for all-items report)

    private static func drawItemRow(item: TrackedItem, y: CGFloat) -> CGFloat {
        let effectiveDue = ItemAnalytics.effectiveDueDate(for: item)
        let status = ItemAnalytics.status(for: item)
        let bgRect = CGRect(x: margin, y: y, width: contentWidth, height: estimatedItemRowHeight(item) - 8)

        // Row background
        UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1).setFill()
        UIBezierPath(roundedRect: bgRect, cornerRadius: 8).fill()

        let innerX = margin + 14
        let innerWidth = contentWidth - 28
        var rowY = y + 12

        // Title + status
        let titleWidth = innerWidth * 0.65
        let statusX = margin + 14 + titleWidth + 8
        let statusWidth = innerWidth - titleWidth - 8

        draw(text: item.title, font: .systemFont(ofSize: 14, weight: .semibold), color: textPrimary,
             at: CGPoint(x: innerX, y: rowY), width: titleWidth, alignment: .left)
        draw(text: status.title, font: .systemFont(ofSize: 11, weight: .medium), color: statusColor(status),
             at: CGPoint(x: statusX, y: rowY + 1), width: statusWidth, alignment: .right)

        rowY += 18

        // Provider + date
        var meta: [String] = []
        if !item.provider.isEmpty { meta.append(item.provider) }
        meta.append((item.isRecurring ? "Next renewal: " : "Due: ") + humanDate(effectiveDue))
        if let amount = item.amount {
            let s = AppFormatters.compactCurrencyString(amount: amount, currencyCode: item.currencyCode)
            meta.append(s + (item.isRecurring ? " / \(item.recurringInterval.shortTitle)" : ""))
        }

        draw(text: meta.joined(separator: "  ·  "), font: .systemFont(ofSize: 11), color: textSecondary,
             at: CGPoint(x: innerX, y: rowY), width: innerWidth, alignment: .left)

        if !item.notesText.isEmpty {
            rowY += 16
            let truncated = item.notesText.count > 120 ? String(item.notesText.prefix(120)) + "…" : item.notesText
            draw(text: truncated, font: .systemFont(ofSize: 11), color: textMuted,
                 at: CGPoint(x: innerX, y: rowY), width: innerWidth, alignment: .left)
        }

        return y + estimatedItemRowHeight(item)
    }

    private static func estimatedItemRowHeight(_ item: TrackedItem) -> CGFloat {
        item.notesText.isEmpty ? 62 : 84
    }

    // MARK: - Section header

    private static func drawSection(title: String, subtitle: String, y: CGFloat) -> CGFloat {
        draw(text: subtitle.uppercased(), font: .systemFont(ofSize: 11, weight: .semibold),
             color: accentColor, at: CGPoint(x: margin, y: y), width: contentWidth, alignment: .left)
        draw(text: title, font: .systemFont(ofSize: 24, weight: .bold),
             color: textPrimary, at: CGPoint(x: margin, y: y + 16), width: contentWidth, alignment: .left)
        return y + 16 + 32
    }

    // MARK: - Detail table

    private static func drawDetailTable(rows: [(String, String)], y: CGFloat) -> CGFloat {
        var currentY = y
        let rowHeight: CGFloat = 32
        let labelWidth = contentWidth * 0.38

        for (index, row) in rows.enumerated() {
            let bgRect = CGRect(x: margin, y: currentY, width: contentWidth, height: rowHeight)
            let bg: UIColor = index.isMultiple(of: 2)
                ? UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
                : .white
            bg.setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: 0).fill()

            let textY = currentY + (rowHeight - 16) / 2
            draw(text: row.0, font: .systemFont(ofSize: 13, weight: .medium), color: textSecondary,
                 at: CGPoint(x: margin + 10, y: textY), width: labelWidth - 10, alignment: .left)
            draw(text: row.1, font: .systemFont(ofSize: 13), color: textPrimary,
                 at: CGPoint(x: margin + labelWidth, y: textY), width: contentWidth - labelWidth - 10, alignment: .left)

            currentY += rowHeight
        }

        // Bottom border
        drawHRule(y: currentY, color: borderColor)
        return currentY + 1
    }

    // MARK: - Status callout

    private static func drawStatusCallout(status: ItemStatus, text: String, y: CGFloat) -> CGFloat {
        let height: CGFloat = 44
        let rect = CGRect(x: margin, y: y, width: contentWidth, height: height)
        let color = statusColor(status).withAlphaComponent(0.08)
        color.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()

        let borderColor = statusColor(status).withAlphaComponent(0.35)
        borderColor.setStroke()
        let border = UIBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 8)
        border.lineWidth = 1
        border.stroke()

        draw(text: text.capitalized, font: .systemFont(ofSize: 14, weight: .semibold),
             color: statusColor(status), at: CGPoint(x: margin + 14, y: y + (height - 16) / 2),
             width: contentWidth - 28, alignment: .left)
        return y + height
    }

    // MARK: - Notes block

    private static func drawNotesBlock(notes: String, y: CGFloat) -> CGFloat {
        draw(text: "NOTES", font: .systemFont(ofSize: 11, weight: .semibold), color: textMuted,
             at: CGPoint(x: margin, y: y), width: contentWidth, alignment: .left)
        let noteY = y + 16
        let attr = NSAttributedString(string: notes, attributes: [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: textPrimary
        ])
        let constraintRect = CGSize(width: contentWidth, height: 400)
        let boundingRect = attr.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin], context: nil)
        attr.draw(in: CGRect(x: margin, y: noteY, width: contentWidth, height: boundingRect.height))
        return noteY + boundingRect.height
    }

    // MARK: - Attachments list

    private static func drawAttachmentsList(attachments: [StoredAttachment], y: CGFloat) -> CGFloat {
        var currentY = y
        draw(text: "ATTACHMENTS", font: .systemFont(ofSize: 11, weight: .semibold), color: textMuted,
             at: CGPoint(x: margin, y: currentY), width: contentWidth, alignment: .left)
        currentY += 16
        for attachment in attachments {
            draw(text: "• \(attachment.originalName) (\(attachment.kind.title))",
                 font: .systemFont(ofSize: 13), color: textSecondary,
                 at: CGPoint(x: margin, y: currentY), width: contentWidth, alignment: .left)
            currentY += 18
        }
        return currentY
    }

    // MARK: - Page header / footer

    @discardableResult
    private static func drawPageHeader(title: String, date: Date, y: CGFloat) -> CGFloat {
        draw(text: "Document Expiry Tracker", font: .systemFont(ofSize: 11, weight: .semibold),
             color: accentColor, at: CGPoint(x: margin, y: y), width: contentWidth * 0.6, alignment: .left)
        draw(text: humanDate(date), font: .systemFont(ofSize: 11), color: textMuted,
             at: CGPoint(x: margin, y: y), width: contentWidth, alignment: .right)
        let lineY = y + 18
        drawHRule(y: lineY, color: borderColor)
        draw(text: title, font: .systemFont(ofSize: 18, weight: .bold), color: textPrimary,
             at: CGPoint(x: margin, y: lineY + 10), width: contentWidth, alignment: .left)
        return lineY + 10 + 24
    }

    private static func drawPageFooter(pageNumber: Int) {
        let y = pageSize.height - margin + 10
        drawHRule(y: y - 10, color: borderColor)
        draw(text: "Generated by Document Expiry Tracker", font: .systemFont(ofSize: 10),
             color: textMuted, at: CGPoint(x: margin, y: y), width: contentWidth * 0.6, alignment: .left)
        draw(text: "Page \(pageNumber)", font: .systemFont(ofSize: 10), color: textMuted,
             at: CGPoint(x: margin, y: y), width: contentWidth, alignment: .right)
    }

    // MARK: - Drawing primitives

    private static func draw(
        text: String,
        font: UIFont,
        color: UIColor,
        at origin: CGPoint,
        width: CGFloat,
        alignment: NSTextAlignment
    ) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        let rect = CGRect(x: origin.x, y: origin.y, width: width, height: 200)
        let ns = text as NSString
        ns.draw(in: rect, withAttributes: attrs)
    }

    private static func drawHRule(y: CGFloat, color: UIColor) {
        color.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
        path.lineWidth = 0.5
        path.stroke()
    }

    // MARK: - Colors

    private static let textPrimary   = UIColor(red: 0.1,  green: 0.1,  blue: 0.12, alpha: 1)
    private static let textSecondary = UIColor(red: 0.38, green: 0.38, blue: 0.42, alpha: 1)
    private static let textMuted     = UIColor(red: 0.60, green: 0.60, blue: 0.64, alpha: 1)
    private static let accentColor   = UIColor(red: 0.29, green: 0.38, blue: 0.96, alpha: 1)
    private static let borderColor   = UIColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1)

    private static func statusColor(_ status: ItemStatus) -> UIColor {
        switch status {
        case .expired:  return UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1)
        case .dueToday: return UIColor(red: 0.92, green: 0.55, blue: 0.15, alpha: 1)
        case .dueSoon:  return UIColor(red: 0.85, green: 0.65, blue: 0.10, alpha: 1)
        case .upcoming, .active: return UIColor(red: 0.20, green: 0.70, blue: 0.40, alpha: 1)
        case .archived: return UIColor(red: 0.55, green: 0.55, blue: 0.60, alpha: 1)
        }
    }

    // MARK: - Date / filename helpers

    private static let humanFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let isoDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()

    private static func humanDate(_ date: Date) -> String {
        humanFormatter.string(from: date)
    }

    private static func singleItemFilename(_ item: TrackedItem) -> String {
        let slug = item.title
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        let date = isoDateFormatter.string(from: Date.now)
        return "item-\(slug)-\(date).pdf"
    }

    private static func defaultSummaryFilename() -> String {
        let date = isoDateFormatter.string(from: Date.now)
        return "expiry-tracker-summary-\(date).pdf"
    }
}
