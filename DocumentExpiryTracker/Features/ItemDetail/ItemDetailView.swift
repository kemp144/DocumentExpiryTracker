import SwiftUI

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager

    let item: TrackedItem

    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                detailsCard
                if !item.notesText.isEmpty { notesCard }
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
        .alert("Delete Item?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) { deleteItem() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the item and its pending reminders.")
        }
        .alert("Action Failed", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
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

            StatusBadgeView(status: status, text: ItemAnalytics.countdownText(for: item))
        }
        .appCardStyle(padding: 22, radius: 24)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(symbol: "calendar", title: "Due Date", value: AppFormatters.shortDate.string(from: item.dueDate))
            if item.isRecurring {
                divider
                detailRow(symbol: "repeat", title: "Recurring", value: item.recurringInterval.title)
            }
            if let amount = item.amount {
                divider
                detailRow(
                    symbol: "dollarsign.circle",
                    title: "Amount",
                    value: "\(AppFormatters.currencyString(amount: amount, currencyCode: item.currencyCode))\(item.isRecurring ? " / \(item.recurringInterval.title.lowercased())" : "")"
                )
            }
            if !item.ownerName.isEmpty {
                divider
                detailRow(symbol: "person.fill", title: "Owner", value: item.ownerName)
            }
            if !item.reminders.isEmpty {
                divider
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.fillSoft)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reminders")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(item.reminders.map(\.title).joined(separator: ", "))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
        }
        .background(AppTheme.elevated)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
}
