import SwiftUI
import SwiftData

struct ItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]) private var items: [TrackedItem]

    let onAddTapped: () -> Void

    @State private var searchText = ""
    @State private var selectedCategory: ItemCategory?
    @State private var selectedStatus: ItemStatus?
    @State private var sortOption: ItemSortOption = .soonest
    @State private var itemPendingDelete: TrackedItem?

    private var filteredItems: [TrackedItem] {
        let searched = items.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                || item.provider.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let status = ItemAnalytics.status(for: item)
            let matchesStatus = selectedStatus == nil || status == selectedStatus
            return matchesSearch && matchesCategory && matchesStatus
        }
        return ItemAnalytics.sort(items: searched, by: sortOption)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header

                if items.isEmpty {
                    EmptyStateView(
                        systemImage: "doc.badge.plus",
                        title: "No items yet",
                        message: "Start tracking your documents, subscriptions, and renewals.",
                        actionTitle: "Add First Item",
                        action: onAddTapped
                    )
                    .padding(.top, 36)
                } else {
                    searchField
                    categoryFilters
                    statusFilters
                    sortHeader

                    if filteredItems.isEmpty {
                        EmptyStateView(
                            systemImage: "magnifyingglass",
                            title: "No results found",
                            message: "Try adjusting your search, filters, or sort order."
                        )
                        .padding(.top, 36)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredItems, id: \.id) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    ItemCardView(item: item)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(item.isArchived ? "Unarchive" : "Archive", systemImage: item.isArchived ? "tray.and.arrow.up.fill" : "archivebox.fill") {
                                        toggleArchive(item)
                                    }
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        itemPendingDelete = item
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Delete Item?", isPresented: Binding(get: { itemPendingDelete != nil }, set: { if !$0 { itemPendingDelete = nil } })) {
            Button("Delete", role: .destructive) {
                if let itemPendingDelete { delete(itemPendingDelete) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the item and its pending reminders.")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Items")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Search renewals, subscriptions, warranties, contracts, and more")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Button {
                onAddTapped()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("items_add")
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.textMuted)
            TextField("Search items...", text: $searchText)
                .foregroundStyle(AppTheme.textPrimary)
                .accessibilityIdentifier("items_search")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.elevated)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(ItemCategory.allCases) { category in
                    filterChip(label: category.pluralTitle, isSelected: selectedCategory == category) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
        }
    }

    private var statusFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "Any Status", isSelected: selectedStatus == nil) { selectedStatus = nil }
                ForEach([ItemStatus.active, .dueSoon, .dueToday, .expired, .archived], id: \.self) { status in
                    filterChip(label: status.title, isSelected: selectedStatus == status) {
                        selectedStatus = selectedStatus == status ? nil : status
                    }
                }
            }
        }
    }

    private var sortHeader: some View {
        HStack {
            Text("\(filteredItems.count) \(filteredItems.count == 1 ? "item" : "items")")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Menu {
                ForEach(ItemSortOption.allCases) { option in
                    Button(option.title) { sortOption = option }
                }
            } label: {
                Label("Sort", systemImage: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.primary)
            }
        }
        .padding(.top, 4)
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? AppTheme.primary : AppTheme.fillSoft)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggleArchive(_ item: TrackedItem) {
        item.archivedAt = item.isArchived ? nil : .now
        item.updatedAt = .now
        try? modelContext.save()
        if item.isArchived {
            notificationManager.removeNotifications(for: item)
        } else {
            Task { await notificationManager.scheduleNotifications(for: item) }
        }
        WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
    }

    private func delete(_ item: TrackedItem) {
        AttachmentStorage.deleteAll(item.attachments)
        notificationManager.removeNotifications(for: item)
        modelContext.delete(item)
        try? modelContext.save()
        WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
        itemPendingDelete = nil
    }
}
