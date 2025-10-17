import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct NotesEntry: TimelineEntry {
    let date: Date
    let notes: [Note]
}

// MARK: - Provider
struct NotesProvider: TimelineProvider {
    func placeholder(in context: Context) -> NotesEntry {
        .init(date: .now, notes: sampleNotes())
    }

    func getSnapshot(in context: Context, completion: @escaping (NotesEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NotesEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 15 minutes to keep things light
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    // Load from shared App Group cache (written by the app after each sync)
    private func loadEntry() -> NotesEntry {
        let cache = WidgetCacheStore.load()
        return .init(date: .now, notes: cache.recentNotes)
    }

    // For placeholder/snapshot
    private func sampleNotes() -> [Note] {
        [
            .init(id: 1, title: "Welcome 👋", content: "This is your recent note.", createdAt: .now, updatedAt: .now),
            .init(id: 2, title: "Second", content: "Notes preview in the widget.", createdAt: .now, updatedAt: .now)
        ]
    }
}

// MARK: - View
struct NotesWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: NotesProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let first = entry.notes.first {
                Text(first.title).font(.headline).lineLimit(1)
                Text(first.content).font(.caption).lineLimit(2)
            } else {
                Text("Notes").font(.headline)
                Text("No recent notes").font(.caption)
            }
            Spacer()
        }
        .padding()
        // Optional deep-link: uncomment after adding URL scheme to app target
        // .widgetURL(URL(string: "notesapp://note/\(entry.notes.first?.id ?? 0)"))
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Recent Notes").font(.headline)
                Spacer()
            }
            if entry.notes.isEmpty {
                Text("No recent notes").font(.caption)
            } else {
                ForEach(entry.notes.prefix(3)) { note in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "note.text")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.title).font(.subheadline).bold().lineLimit(1)
                            Text(note.content).font(.caption).lineLimit(1)
                        }
                        Spacer()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        // Optional deep-link: uncomment after adding URL scheme to app target
        // .widgetURL(URL(string: "notesapp://home"))
    }
}

// MARK: - Widget Configuration
struct NotesWidget: Widget {
    let kind: String = "NotesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NotesProvider()) { entry in
            NotesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recent Notes")
        .description("Shows your most recent notes.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
