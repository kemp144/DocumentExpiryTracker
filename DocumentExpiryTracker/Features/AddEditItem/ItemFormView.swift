import SwiftUI
import SwiftData

enum ItemFormMode {
    case add
    case edit(TrackedItem)

    var navigationTitle: String {
        switch self {
        case .add: "Add Item"
        case .edit: "Edit Item"
        }
    }

    var submitTitle: String {
        switch self {
        case .add: "Add Item"
        case .edit: "Save Changes"
        }
    }

    var existingItem: TrackedItem? {
        switch self {
        case .add: nil
        case .edit(let item): item
        }
    }
}

struct ItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query private var allItems: [TrackedItem]

    let mode: ItemFormMode

    @State private var draft: ItemDraft
    @State private var showingPaywall = false
    @State private var alertMessage: String?
    @State private var saveTaskInFlight = false

    init(mode: ItemFormMode) {
        self.mode = mode
        _draft = State(initialValue: mode.existingItem.map(ItemDraft.init) ?? ItemDraft())
    }

    private var currencyOptions: [String] {
        FeatureGate.availableCurrencies(isPro: purchaseManager.isProUnlocked)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    categorySection
                    textFieldSection(title: "Title", text: $draft.title, prompt: "e.g. Passport, Netflix, Car Insurance", id: "itemForm_title")
                    textFieldSection(title: "Provider / Company", text: $draft.provider, prompt: "Optional")
                    dateSection
                    recurringSection
                    amountSection
                    textFieldSection(title: "Owner / Person", text: $draft.owner, prompt: "Optional")
                    remindersSection
                    notesSection
                    archiveSection

                    if notificationManager.authorizationStatus == .denied {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notifications are off")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("You can still save reminders here, but iPhone notifications are currently disabled in Settings.")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .appCardStyle()
                    }

                    Button(saveTaskInFlight ? "Saving..." : mode.submitTitle) {
                        save()
                    }
                    .buttonStyle(AppFilledButtonStyle(isLarge: true))
                    .disabled(saveTaskInFlight || !draft.isValid)
                    .accessibilityIdentifier("itemForm_save_bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.fillSoft)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(draft.isValid ? AppTheme.primary : AppTheme.textMuted)
                        .disabled(!draft.isValid || saveTaskInFlight)
                        .accessibilityIdentifier("itemForm_save")
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("Unable to Save", isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Category")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(ItemCategory.allCases) { category in
                    Button {
                        draft.category = category
                    } label: {
                        VStack(spacing: 8) {
                            CategoryIconView(category: category, size: 22)
                            Text(category.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(draft.category == category ? AppTheme.primary.opacity(0.12) : AppTheme.elevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(draft.category == category ? AppTheme.primary : AppTheme.border, lineWidth: draft.category == category ? 1.5 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Due Date")
            DatePicker(
                "",
                selection: $draft.dueDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.top, 4)
            .appCardStyle()
        }
    }

    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Recurring")
            VStack(spacing: 12) {
                Toggle(isOn: Binding(
                    get: { draft.recurringInterval != .none },
                    set: { draft.recurringInterval = $0 ? .monthly : .none }
                )) {
                    Text("Recurring")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .tint(AppTheme.success)

                if draft.recurringInterval != .none {
                    Picker("Interval", selection: $draft.recurringInterval) {
                        Text("Monthly").tag(RecurringInterval.monthly)
                        Text("Yearly").tag(RecurringInterval.yearly)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .appCardStyle()
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Amount")
            HStack(spacing: 10) {
                Menu {
                    ForEach(currencyOptions, id: \.self) { code in
                        Button(code) {
                            draft.currencyCode = code
                        }
                    }
                    if !purchaseManager.isProUnlocked {
                        Divider()
                        Button("Unlock all currencies") {
                            showingPaywall = true
                        }
                    }
                } label: {
                    HStack {
                        Text(draft.currencyCode)
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 88)
                    .padding(.vertical, 14)
                    .background(AppTheme.elevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .accessibilityIdentifier("itemForm_currency")

                TextField("0.00", text: $draft.amountText)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(AppTheme.elevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .foregroundStyle(AppTheme.textPrimary)
                    .accessibilityIdentifier("itemForm_amount")
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Reminders")
            FlexibleChipLayout(spacing: 8, lineSpacing: 8) {
                ForEach(ReminderOffset.allCases) { offset in
                    let selected = draft.reminders.contains(offset)
                    Button(offset.title) {
                        toggleReminder(offset)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(selected ? Color.white : AppTheme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(selected ? AppTheme.primary : AppTheme.elevated)
                    .overlay(
                        Capsule()
                            .stroke(selected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("reminder_\(offset.rawValue)")
                }
            }
            .appCardStyle()
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Notes")
            TextField("Add any additional notes...", text: $draft.notes, axis: .vertical)
                .lineLimit(4, reservesSpace: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .foregroundStyle(AppTheme.textPrimary)
                .accessibilityIdentifier("itemForm_notes")
        }
    }

    private var archiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Advanced")
            Toggle(isOn: $draft.isArchived) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Archive item")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Archived items stay saved but are excluded from active summaries.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .tint(AppTheme.success)
            .appCardStyle()
        }
    }

    private func textFieldSection(title: String, text: Binding<String>, prompt: String, id: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title)
            TextField(prompt, text: text)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .foregroundStyle(AppTheme.textPrimary)
                .accessibilityIdentifier(id ?? title)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppTheme.textPrimary)
    }

    private func toggleReminder(_ offset: ReminderOffset) {
        var next = draft.reminders
        if next.contains(offset) {
            next.remove(offset)
        } else {
            if !FeatureGate.canUseReminderCount(next.count + 1, isPro: purchaseManager.isProUnlocked) {
                showingPaywall = true
                return
            }
            next.insert(offset)
        }
        draft.reminders = next
    }

    private func save() {
        guard draft.isValid else {
            alertMessage = draft.validationMessage ?? "Please complete the required fields."
            return
        }

        if case .add = mode,
           !FeatureGate.canAddItem(existingItemCount: allItems.count, isPro: purchaseManager.isProUnlocked) {
            showingPaywall = true
            return
        }

        if !FeatureGate.canUseReminderCount(draft.reminders.count, isPro: purchaseManager.isProUnlocked) {
            showingPaywall = true
            return
        }

        saveTaskInFlight = true

        let savedItem: TrackedItem
        switch mode {
        case .add:
            let item = draft.makeItem()
            modelContext.insert(item)
            savedItem = item
        case .edit(let item):
            draft.apply(to: item)
            savedItem = item
        }

        do {
            try modelContext.save()
            Task {
                await notificationManager.refreshStatus()
                if draft.isArchived {
                    notificationManager.removeNotifications(for: savedItem)
                } else {
                    await notificationManager.scheduleNotifications(for: savedItem)
                }
                WidgetSnapshotService.sync(context: modelContext, isProUnlocked: purchaseManager.isProUnlocked)
                saveTaskInFlight = false
                dismiss()
            }
        } catch {
            saveTaskInFlight = false
            alertMessage = error.localizedDescription
        }
    }
}

private struct FlexibleChipLayout<Content: View>: View {
    let spacing: CGFloat
    let lineSpacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
