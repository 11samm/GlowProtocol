import WidgetKit
import SwiftUI

// Decodes only a small App Group snapshot; never opens the app's SwiftData store.
private struct DailySnapshot: Codable {
    let version: Int
    let date: Date
    let day: Int
    let target: Int
    let streak: Int
    let completed: Int
    let required: Int
    let remaining: [String]
    let hideHabitNames: Bool
    let hasAccess: Bool
}
struct GlowDailyEntry: TimelineEntry {
    let date: Date
    fileprivate let snapshot: DailySnapshot?
    let isPlaceholder: Bool
}
struct GlowDailyProvider: TimelineProvider {
    func placeholder(in context: Context) -> GlowDailyEntry {
        GlowDailyEntry(date: .now, snapshot: DailySnapshot(version: 1, date: .now, day: 12, target: 75, streak: 4, completed: 3, required: 5, remaining: ["Read", "Move"], hideHabitNames: true, hasAccess: true), isPlaceholder: true)
    }
    func getSnapshot(in context: Context, completion: @escaping (GlowDailyEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : read())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<GlowDailyEntry>) -> Void) {
        let now = Date.now
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now)) ?? now.addingTimeInterval(3600)
        // A midnight entry prevents yesterday's completed ring remaining on today's screen.
        let current = read()
        let rollover = GlowDailyEntry(date: nextMidnight, snapshot: current.snapshot, isPlaceholder: false)
        completion(Timeline(entries: [current, rollover], policy: .after(min(nextMidnight, now.addingTimeInterval(1800)))))
    }
    private func read() -> GlowDailyEntry {
        let data = UserDefaults(suiteName: "group.sam.GlowProtocol")?.data(forKey: "glowWidgetSnapshot.v1")
        let snapshot = data.flatMap { try? JSONDecoder().decode(DailySnapshot.self, from: $0) }
        return GlowDailyEntry(date: .now, snapshot: snapshot?.version == 1 ? snapshot : nil, isPlaceholder: false)
    }
}
struct GlowDailyProgressWidget: Widget {
    let kind = "GlowDailyProgress"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GlowDailyProvider()) { entry in
            GlowDailyWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color(UIColor.systemBackground) }
                .widgetURL(URL(string: "glowprotocol://today"))
        }
        .configurationDisplayName("Your daily glow")
        .description("Your day, streak, and daily completion at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
private struct GlowDailyWidgetView: View {
    let entry: GlowDailyEntry
    @Environment(\.widgetFamily) private var family
    var body: some View {
        if let s = entry.snapshot, s.hasAccess {
            let isToday = Calendar.current.isDate(s.date, inSameDayAs: entry.date)
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("GLOW PROTOCOL").font(.system(size: 9, weight: .semibold)).tracking(1)
                    Text(isToday ? "Day \(s.day) / \(s.target)" : "A new day").font(.system(.headline, design: .serif))
                    HStack(spacing: 10) {
                        ZStack {
                            Circle().stroke(Color.secondary.opacity(0.15), lineWidth: 4)
                            Circle().trim(from: 0, to: isToday && s.required > 0 ? CGFloat(s.completed) / CGFloat(s.required) : 0)
                                .stroke(Color(red: 0.34, green: 0.43, blue: 0.32), style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                            Text(isToday ? "\(s.completed)/\(s.required)" : "—").font(.caption.weight(.medium))
                        }.frame(width: 48, height: 48)
                        if family == .systemMedium {
                            Text(isToday ? "Today so far" : "Open for today's progress").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Text(isToday ? "\(s.streak) day streak" : "Open to update").font(.caption2).foregroundStyle(.secondary)
                }
                if family == .systemMedium && isToday {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(s.completed == s.required && s.required > 0 ? "All done today" : "Still to come").font(.caption.weight(.semibold))
                        if s.hideHabitNames {
                            Text("\(max(0, s.required-s.completed)) habits remaining").font(.caption).foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(s.remaining.enumerated()), id: \.offset) { _, name in
                                Text("○  \(name)").font(.caption).lineLimit(1)
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).accessibilityElement(children: .combine)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Glow Protocol").font(.system(.title3, design: .serif))
                Text("Your 75 days, one day at a time.").font(.caption).foregroundStyle(.secondary)
                Text("Open the app").font(.caption.weight(.semibold))
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
#Preview(as: .systemSmall) {
    GlowDailyProgressWidget()
} timeline: {
    GlowDailyEntry(date: .now, snapshot: nil, isPlaceholder: false)
}
