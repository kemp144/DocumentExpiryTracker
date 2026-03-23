import EventKitUI
import PhotosUI
import QuickLook
import SwiftUI
import UniformTypeIdentifiers

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager

    let item: TrackedItem

    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false
    @State private var errorMessage: String?
    @State private var paywallContext: PaywallContext?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingFileImporter = false
    @State private var previewDocument: PreviewDocument?

    // Export state
    @State private var shareItems: [Any] = []
    @State private var showingShareSheet = false

    // Calendar state
    @StateObject private var calendarService = CalendarService()
    @State private var showingCalendarEditor = false
    @State private var calendarSuccessMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                detailsCard
                attachmentsCard
                if !item.notesText.isEmpty { notesCard }
                exportActionsCard
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.primary)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ItemFormView(mode: .edit(item))
        }
        .sheet(item: $paywallContext) { context in
            PaywallView(context: context)
        }
        .sheet(item: $previewDocument) { document in
            AttachmentPreviewController(url: document.url)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
        .sheet(isPresented: $showingCalendarEditor) {
            NavigationStack {
                EventEditView(
                    event: calendarService.buildEvent(for: item),
                    store: calendarService.eventStore
                ) { action in
                    showingCalendarEditor = false
                    if action == .saved {
                        calendarSuccessMessage = "Event added to Calendar."
                    }
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .image, .text, .item],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else { return }
            Task { await importPhoto(newValue) }
        }
        .alert("Delete Item?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) { deleteItem() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the item, its pending reminders, and any attached files.")
        }
        .alert("Action Failed", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Added to Calendar", isPresented: Binding(get: { calendarSuccessMessage != nil }, set: { if !$0 { calendarSuccessMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(calendarSuccessMessage ?? "")
        }
    }

    private var displayDueDate: Date {
        ItemAnalytics.effectiveDueDate(for: item)
    }

    private var headerCard: some View {
        let status = ItemAnalytics.status(for: item)

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                CategoryIconView(category: item.category, size: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.category.title)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(item.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if !item.provider.isEmpty {
                        Text(item.provider)
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                Spacer()
            }

            HStack(spacing: 10) {
                StatusBadgeView(status: status, text: ItemAnalytics.countdownText(for: item))
                if item.isRecurring {
                    Text(item.recurringInterval.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.purple.opacity(0.26))
                        .clipShape(Capsule())
                }
            }

            Text(item.isRecurring ? "Stay ahead of the next renewal and keep the details attached." : "Keep this important item organized and never lose the due date.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .appCardStyle(padding: 22, radius: 24)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(
                symbol: "calendar",
                title: item.isRecurring ? "Next Renewal" : "Due Date",
                value: AppFormatters.shortDate.string(from: displayDueDate)
            )
            divider
            detailRow(symbol: "clock.fill", title: "Status", value: ItemAnalytics.urgencyTitle(for: item))
            if item.isRecurring {
                divider
                detailRow(symbol: "repeat", title: "Repeats", value: item.recurringInterval.title)
            }
            if let amount = item.amount {
                divider
                detailRow(
                    symbol: "dollarsign.circle",
                    title: "Cost",
                    value: "\(AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode))\(item.isRecurring ? " / \(item.recurringInterval.title.lowercased())" : "")"
                )
            }
            if !item.ownerName.isEmpty {
                divider
                detailRow(symbol: "person.fill", title: "Owner", value: item.ownerName)
            }
            if !item.reminders.isEmpty {
                divider
                detailRow(symbol: "bell.fill", title: "Reminders", value: item.reminders.map(\.title).joined(separator: ", "))
            }
        }
        .background(AppTheme.elevated)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var attachmentsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Attachments")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if purchaseManager.isProUnlocked {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Photo", systemImage: "photo")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.primary)
                    }

                    Button {
                        showingFileImporter = true
                    } label: {
                        Label("File", systemImage: "paperclip")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }

            if purchaseManager.isProUnlocked {
                if item.attachments.isEmpty {
                    Text("Attach scans, photos, or PDFs so everything important stays with this item.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    VStack(spacing: 10) {
                        ForEach(item.attachments) { attachment in
                            AttachmentRowView(attachment: attachment) {
                                previewDocument = PreviewDocument(url: AttachmentStorage.fileURL(for: attachment))
                            } onDelete: {
                                deleteAttachment(attachment)
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Unlock Pro to add scans, images, and PDFs to this item.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Button("Unlock Attachments") {
                        paywallContext = .attachments
                    }
                    .buttonStyle(AppFilledButtonStyle())
                }
            }
        }
        .appCardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(item.notesText)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(2)
        }
        .appCardStyle()
    }

    // MARK: - Export Actions Card

    private var exportActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Export & Calendar")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 0) {
                exportActionRow(
                    symbol: "calendar.badge.plus",
                    title: "Add to Calendar",
                    subtitle: calendarRowSubtitle,
                    isPro: true
                ) {
                    handleAddToCalendar()
                }

                Divider()
                    .overlay(AppTheme.border)
                    .padding(.leading, 56)

                exportActionRow(
                    symbol: "doc.richtext",
                    title: "Export as PDF",
                    subtitle: "Save or share a summary of this item",
                    isPro: true
                ) {
                    handleExportSinglePDF()
                }

                Divider()
                    .overlay(AppTheme.border)
                    .padding(.leading, 56)

                exportActionRow(
                    symbol: "tablecells",
                    title: "Export as CSV",
                    subtitle: "Export this item's data in spreadsheet format",
                    isPro: true
                ) {
                    handleExportSingleCSV()
                }
            }
            .background(AppTheme.elevated)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var calendarRowSubtitle: String {
        switch calendarService.authorizationStatus {
        case .denied, .restricted:
            return "Calendar access denied — tap to open Settings"
        case .fullAccess:
            return "Add this item's due date to Apple Calendar"
        default:
            return "Add this item's due date to Apple Calendar"
        }
    }

    private func exportActionRow(
        symbol: String,
        title: String,
        subtitle: String,
        isPro: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.fillSoft)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        if isPro && !purchaseManager.isProUnlocked {
                            Text("PRO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppTheme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.primary.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export Handlers

    private func handleAddToCalendar() {
        guard purchaseManager.isProUnlocked else {
            paywallContext = .calendarIntegration
            return
        }

        calendarService.refreshStatus()

        switch calendarService.authorizationStatus {
        case .denied, .restricted:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        case .fullAccess:
            showingCalendarEditor = true
        case .notDetermined:
            Task {
                let granted = await calendarService.requestAccess()
                if granted {
                    showingCalendarEditor = true
                } else {
                    errorMessage = "Calendar access was not granted. You can enable it in Settings."
                }
            }
        default:
            // writeOnly or other — request full access
            Task {
                let granted = await calendarService.requestAccess()
                if granted {
                    showingCalendarEditor = true
                } else {
                    errorMessage = "Calendar access was not granted. You can enable it in Settings."
                }
            }
        }
    }

    private func handleExportSinglePDF() {
        guard purchaseManager.isProUnlocked else {
            paywallContext = .pdfExport
            return
        }
        let url = PDFExportService.singleItemFile(for: item)
        // Show QuickLook preview directly for generated PDF
        previewDocument = PreviewDocument(url: url)
    }

    private func handleExportSingleCSV() {
        guard purchaseManager.isProUnlocked else {
            paywallContext = .csvExport
            return
        }
        let url = CSVExportService.temporaryFile(for: [item])
        shareItems = [url]
        showingShareSheet = true
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit Item", systemImage: "square.and.pencil")
            }
            .buttonStyle(AppSecondaryButtonStyle())
            .accessibilityIdentifier("detail_edit")

            Button {
                toggleArchive()
            } label: {
                Label(item.isArchived ? "Unarchive" : "Archive", systemImage: item.isArchived ? "tray.and.arrow.up.fill" : "archivebox.fill")
            }
            .buttonStyle(AppSecondaryButtonStyle())
            .accessibilityIdentifier("detail_archive")

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(AppTheme.danger)
                    .background(AppTheme.elevated)
                    .overlay(Capsule().stroke(AppTheme.danger.opacity(0.32), lineWidth: 1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("detail_delete")
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.border)
            .frame(height: 1)
    }

    private func detailRow(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 36, height: 36)
                .background(AppTheme.fillSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()
        }
        .padding(16)
    }

    private func toggleArchive() {
        item.archivedAt = item.isArchived ? nil : .now
        item.updatedAt = .now
        do {
            try modelContext.save()
            if item.isArchived {
                notificationManager.removeNotifications(for: item)
            } else {
                Task { await notificationManager.scheduleNotifications(for: item) }
            }
            WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteItem() {
        AttachmentStorage.deleteAll(item.attachments)
        notificationManager.removeNotifications(for: item)
        modelContext.delete(item)
        do {
            try modelContext.save()
            WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importPhoto(_ pickerItem: PhotosPickerItem) async {
        guard purchaseManager.isProUnlocked else {
            paywallContext = .attachments
            return
        }

        do {
            guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
                errorMessage = "That photo could not be loaded."
                return
            }
            let attachment = try AttachmentStorage.importPhotoData(data, suggestedName: "Photo")
            var attachments = item.attachments
            attachments.append(attachment)
            item.attachments = attachments
            item.updatedAt = .now
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard purchaseManager.isProUnlocked else {
            paywallContext = .attachments
            return
        }

        do {
            guard let url = try result.get().first else { return }
            let attachment = try AttachmentStorage.importFile(at: url)
            var attachments = item.attachments
            attachments.append(attachment)
            item.attachments = attachments
            item.updatedAt = .now
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteAttachment(_ attachment: StoredAttachment) {
        AttachmentStorage.delete(attachment)
        var attachments = item.attachments
        attachments.removeAll { $0.id == attachment.id }
        item.attachments = attachments
        item.updatedAt = .now
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct AttachmentRowView: View {
    let attachment: StoredAttachment
    let onPreview: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPreview) {
                if attachment.kind == .image,
                   let data = try? Data(contentsOf: AttachmentStorage.fileURL(for: attachment)),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(AppTheme.border, lineWidth: 1))
                } else {
                    Image(systemName: attachment.kind.symbolName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(attachment.originalName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Text(attachment.kind.title)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.danger)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

private struct PreviewDocument: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct AttachmentPreviewController: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {}

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
