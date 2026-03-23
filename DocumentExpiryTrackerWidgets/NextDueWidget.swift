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
                provider: "US Government"
            ),
            isProUnlocked: false
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
            return NextDueEntry(date: .now, item: nil, isProUnlocked: false)
        }

        let fileURL = containerURL.appendingPathComponent(WidgetSnapshotStore.fileName)
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(WidgetSnapshotPayload.self, from: data)
        else {
            return NextDueEntry(date: .now, item: nil, isProUnlocked: false)
        }

        let nextItem = payload.items.sorted { $0.dueDate < $1.dueDate }.first
        return NextDueEntry(date: .now, item: nextItem, isProUnlocked: payload.isProUnlocked)
    }
}

struct NextDueWidgetEntryView: View {
    var entry: NextDueProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A84FF"), Color(hex: "5E5CE6")], startPoint: .topLeading, endPoint: .bottomTrailing)

            if let item = entry.item {
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

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Due")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.72))
                        Text(item.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.white)
                            .lineLimit(2)
                        if !item.provider.isEmpty {
                            Text(item.provider)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.82))
                                .lineLimit(1)
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
