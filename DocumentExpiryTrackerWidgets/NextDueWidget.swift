import SwiftUI
import WidgetKit

private extension Color {
    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        self.init(
            .sRGB,
            red: Double((value & 0xFF0000) >> 16) / 255,
            green: Double((value & 0x00FF00) >> 8) / 255,
            blue: Double(value & 0x0000FF) / 255,
            opacity: 1
        )
    }
}

struct NextDueEntry: TimelineEntry {
    let date: Date
    let item: WidgetItemSnapshot?
    let isProUnlocked: Bool
    let dueSoonCount: Int
    let monthlyRecurringTotal: [String: Double]
}

struct NextDueProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextDueEntry {
        NextDueEntry(
            date: .now,
            item: WidgetItemSnapshot(
                id: UUID(),
                title: "Passport",
                categoryRaw: ItemCategory.document.rawValue,
                dueDate: Calendar.current.date(byAdding: .day, value: 12, to: .now) ?? .now,
                provider: "US Government",
                recurringLabel: nil,
                monthlyAmount: nil
            ),
            isProUnlocked: false,
            dueSoonCount: 2,
            monthlyRecurringTotal: ["USD": 15.99]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextDueEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextDueEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now.addingTimeInterval(10_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadEntry() -> NextDueEntry {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetSnapshotStore.appGroupIdentifier) else {
            return NextDueEntry(date: .now, item: nil, isProUnlocked: false, dueSoonCount: 0, monthlyRecurringTotal: [:])
        }

        let fileURL = containerURL.appendingPathComponent(WidgetSnapshotStore.fileName)
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(WidgetSnapshotPayload.self, from: data)
        else {
            return NextDueEntry(date: .now, item: nil, isProUnlocked: false, dueSoonCount: 0, monthlyRecurringTotal: [:])
        }

        let nextItem = payload.items.sorted { $0.dueDate < $1.dueDate }.first
        return NextDueEntry(
            date: .now,
            item: nextItem,
            isProUnlocked: payload.isProUnlocked,
            dueSoonCount: payload.dueSoonCount,
            monthlyRecurringTotal: payload.monthlyRecurringTotal
        )
    }
}

struct NextDueWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: NextDueProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A84FF"), Color(hex: "5E5CE6")], startPoint: .topLeading, endPoint: .bottomTrailing)

            if !entry.isProUnlocked {
                lockedWidget
            } else if let item = entry.item {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: item.category.symbolName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.94))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        Spacer()
                        Text(WidgetCountdownFormatter.text(for: item.dueDate))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Next Due")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.72))
                        Text(item.title)
                            .font(.system(size: family == .systemSmall ? 18 : 20, weight: .bold))
                            .foregroundStyle(Color.white)
                            .lineLimit(2)
                        if !item.provider.isEmpty {
                            Text(item.provider)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.82))
                                .lineLimit(1)
                        }
                        if family == .systemMedium {
                            HStack(spacing: 10) {
                                statPill(title: "Due soon", value: "\(entry.dueSoonCount)")
                                statPill(title: "Monthly", value: formatMultiCurrency(totals: entry.monthlyRecurringTotal))
                            }
                        } else if let recurringLabel = item.recurringLabel {
                            Text(recurringLabel)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.84))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Document Expiry Tracker")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.88))
                    Spacer()
                    Text("Add your first item to see your next due date here.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white)
                }
                .padding(16)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color(hex: "0A84FF"), Color(hex: "5E5CE6")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var lockedWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Spacer()

            Text("Widgets are part of Pro")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.white)
            Text("Unlock Pro in the app to see upcoming renewals here.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.86))
                .lineLimit(3)
        }
        .padding(16)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.72))
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatMultiCurrency(totals: [String: Double]) -> String {
        if totals.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            return formatter.string(from: 0) ?? "$0"
        }
        let sortedKeys = totals.keys.sorted()
        let parts = sortedKeys.compactMap { code -> String? in
            let amount = totals[code]!
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = code
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount))
        }
        return parts.joined(separator: " + ")
    }
}

struct NextDueWidget: Widget {
    let kind = "NextDueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextDueProvider()) { entry in
            NextDueWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Due")
        .description("Shows the next item due in Document Expiry Tracker.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
