import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    // We create a ModelContainer for the widget's context
    let modelContainer = SharedModelContainer.create()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), benefitName: "Uber Cash", cardName: "Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Try to fetch real data for the snapshot
        let currentDate = Date()
        let descriptor = FetchDescriptor<CardBenefit>(
            predicate: #Predicate { !$0.isUsed },
            sortBy: [SortDescriptor(\.nextResetDate)]
        )
        
        do {
            let context = ModelContext(modelContainer)
            let benefits = try context.fetch(descriptor)
            
            if let first = benefits.first {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: currentDate, to: first.nextResetDate)
                let days = components.day ?? 0
                
                let entry = SimpleEntry(
                    date: currentDate,
                    benefitName: first.name,
                    cardName: first.cardName,
                    amount: first.amount,
                    daysRemaining: days,
                    isUrgent: days <= 5
                )
                completion(entry)
                return
            }
        } catch {
            // Fallthrough to placeholder if fetch fails or throws
        }
        
        // Fallback if no data found or error (e.g. initially empty)
        let entry = SimpleEntry(date: Date(), benefitName: "Example: Uber Cash", cardName: "Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        // Fetch the most urgent benefit
        var entry: SimpleEntry
        
        let descriptor = FetchDescriptor<CardBenefit>(
            predicate: #Predicate { !$0.isUsed },
            sortBy: [SortDescriptor(\.nextResetDate)]
        )
        
        do {
            let context = ModelContext(modelContainer)
            let benefits = try context.fetch(descriptor)
            
            if let first = benefits.first {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: currentDate, to: first.nextResetDate)
                let days = components.day ?? 0
                
                entry = SimpleEntry(
                    date: currentDate,
                    benefitName: first.name,
                    cardName: first.cardName,
                    amount: first.amount,
                    daysRemaining: days,
                    isUrgent: days <= 5
                )
            } else {
                // No benefits or all used.
                // Could also mean App Group is not working.
                entry = SimpleEntry(date: currentDate, benefitName: "No Data Found", cardName: "Check App Group ID?", amount: 0, daysRemaining: 0, isUrgent: false)
            }
        } catch {
            entry = SimpleEntry(date: currentDate, benefitName: "Error Loading", cardName: "Database Error", amount: 0, daysRemaining: 0, isUrgent: false)
        }

        // Refresh every hour or when app foregrounds (handled by system mostly)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let benefitName: String
    let cardName: String
    let amount: Double
    let daysRemaining: Int
    let isUrgent: Bool
}

struct TrackMyCardWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.benefitName == "No Data Found" || entry.benefitName == "Error Loading" {
                ContentUnavailableView(entry.benefitName, systemImage: "exclamationmark.triangle", description: Text(entry.cardName))
                    .font(.caption)
            } else if entry.benefitName == "All Caught Up!" {
                ContentUnavailableView("All Done", systemImage: "checkmark.circle", description: Text("No benefits pending."))
                    .font(.caption)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(entry.isUrgent ? .red : .orange)
                        .opacity(entry.isUrgent || entry.daysRemaining <= 10 ? 1 : 0)
                    Text(entry.isUrgent ? "Act Now" : "Upcoming")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(entry.isUrgent ? .red : .secondary)
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Text(entry.benefitName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(entry.cardName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.amount, format: .currency(code: "USD"))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(entry.daysRemaining == 0 ? "Ends Today" : "\(entry.daysRemaining)d left")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(entry.isUrgent ? .red : .secondary)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct TrackMyCardWidget: Widget {
    let kind: String = "TrackMyCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TrackMyCardEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TrackMyCardEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Upcoming Benefit")
        .description("Shows the benefit that expires soonest.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

typealias TrackMyCardEntryView = TrackMyCardWidgetEntryView

#Preview(as: .systemSmall) {
    TrackMyCardWidget()
} timeline: {
    SimpleEntry(date: .now, benefitName: "Uber Cash", cardName: "Platinum Card", amount: 15.0, daysRemaining: 3, isUrgent: true)
    SimpleEntry(date: .now, benefitName: "Dining Credit", cardName: "Gold Card", amount: 10.0, daysRemaining: 12, isUrgent: false)
}