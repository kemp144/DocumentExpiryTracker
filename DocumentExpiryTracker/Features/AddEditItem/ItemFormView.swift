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
    @EnvironmentObject private var settings: AppSettings
    @Query private var allItems: [TrackedItem]

    let mode: ItemFormMode

    @State private var draft: ItemDraft
    @State private var paywallContext: PaywallContext?
    @State private var alertMessage: String?
    @State private var saveTaskInFlight = false
    @State private var showingDatePicker = false
    @State private var showingAdvancedDetails: Bool

    init(mode: ItemFormMode) {
        self.mode = mode
        let initialDraft = mode.existingItem.map(ItemDraft.init) ?? ItemDraft()
        _draft = State(initialValue: initialDraft)
        _showingAdvancedDetails = State(initialValue: mode.existingItem != nil || initialDraft.recurringInterval != .none || !initialDraft.notes.isEmpty || !initialDraft.owner.isEmpty || initialDraft.isArchived)
    }

    private var currencyOptions: [String] {
        FeatureGate.availableCurrencies(isPro: purchaseManager.isProUnlocked)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if case .add = mode {
                        templateSection
                    }

                    categorySection
                    compactFieldSection(title: "Title", text: $draft.title, prompt: "Passport, Netflix, Car Insurance", id: "itemForm_title")
                    compactFieldSection(title: "Provider / Company", text: $draft.provider, prompt: "Optional")
                    dueDateSection
                    remindersSection
                    advancedDetailsSection

                    if notificationManager.authorizationStatus == .denied {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notifications are off")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("You can still save reminder times here, but iPhone notifications are currently disabled in Settings.")
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
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if case .add = mode, draft.amountText.isEmpty {
                draft.currencyCode = settings.defaultCurrency
            }
        }
        .sheet(item: $paywallContext) { context in
            PaywallView(context: context)
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "Due date",
                        selection: $draft.dueDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    Spacer()
                }
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Unable to Save", isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Quick Templates")
            Text("Start with a common renewal and edit anything after.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(QuickTemplate.all) { template in
                        Button {
                            applyTemplate(template)
                        } label: {
                            Text(template.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.fillSoft)
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
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

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Due Date")
            Button {
                showingDatePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.primary.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppFormatters.shortDate.string(from: draft.dueDate))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Tap to choose the next due or renewal date")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("itemForm_dueDate")
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Reminders")
            Text("Choose when you want a heads-up before this item is due.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)

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

    private var advancedDetailsSection: some View {
        DisclosureGroup(isExpanded: $showingAdvancedDetails) {
            VStack(alignment: .leading, spacing: 18) {
                recurringSection
                amountSection
                compactFieldSection(title: "Owner / Person", text: $draft.owner, prompt: "Optional")
                notesSection
                attachmentsHint
                archiveSection
            }
            .padding(.top, 16)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("More Details")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Add costs, notes, recurrence, and other optional details.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }
        }
        .tint(AppTheme.textPrimary)
        .appCardStyle()
    }

    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Recurring")
            Toggle(isOn: Binding(
                get: { draft.recurringInterval != .none },
                set: { draft.recurringInterval = $0 ? .monthly : .none }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repeat this item")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Great for subscriptions, insurance, and yearly renewals.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
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
                            paywallContext = .currencies
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

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Notes")
            TextField("Add any context you want to remember...", text: $draft.notes, axis: .vertical)
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

    private var attachmentsHint: some View {
        Button {
            paywallContext = purchaseManager.isProUnlocked ? nil : .attachments
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "paperclip")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.fillSoft)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Attachments")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(purchaseManager.isProUnlocked ? "You can add files and scans after saving this item." : "Unlock Pro to attach scans, PDFs, and photos after saving.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
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
        }
    }

    private func compactFieldSection(title: String, text: Binding<String>, prompt: String, id: String? = nil) -> some View {
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

    private func applyTemplate(_ template: QuickTemplate) {
        draft.title = template.title
        draft.category = template.category
        draft.provider = template.provider
        draft.recurringInterval = template.recurringInterval
        draft.reminders = template.defaultReminders
        showingAdvancedDetails = showingAdvancedDetails || template.recurringInterval != .none
    }

    private func toggleReminder(_ offset: ReminderOffset) {
        var next = draft.reminders
        if next.contains(offset) {
            next.remove(offset)
        } else {
            if !FeatureGate.canUseReminderCount(next.count + 1, isPro: purchaseManager.isProUnlocked) {
                paywallContext = .multipleReminders
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
            paywallContext = .itemLimit
            return
        }

        if !FeatureGate.canUseReminderCount(draft.reminders.count, isPro: purchaseManager.isProUnlocked) {
            paywallContext = .multipleReminders
            return
        }

        saveTaskInFlight = true
        let shouldQueueSoftPrompt = !purchaseManager.isProUnlocked && allItems.isEmpty && !draft.reminders.isEmpty

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
                if shouldQueueSoftPrompt {
                    settings.queueSoftUpgradePromptIfNeeded()
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
        ChipFlowLayout(spacing: spacing, lineSpacing: lineSpacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ChipFlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableWidth = proposal.width ?? 320
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > availableWidth, rowWidth > 0 {
                height += rowHeight + lineSpacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + (i < subviews.count - 1 ? spacing : 0)
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: availableWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
