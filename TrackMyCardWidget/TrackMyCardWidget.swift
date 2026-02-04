import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    // We create a ModelContainer for the widget's context
    let modelContainer = SharedModelContainer.create()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), benefits: [
            WidgetBenefit(name: "Uber Cash", cardName: "Amex Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true),
            WidgetBenefit(name: "Dining Credit", cardName: "Amex Gold", amount: 10.0, daysRemaining: 8, isUrgent: false),
            WidgetBenefit(name: "Uber Cash", cardName: "Amex Gold", amount: 10.0, daysRemaining: 12, isUrgent: false)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let currentDate = Date()
        let descriptor = FetchDescriptor<CardBenefit>(
            predicate: #Predicate { !$0.isUsed },
            sortBy: [SortDescriptor(\.nextResetDate)]
        )
        
        do {
            let context = ModelContext(modelContainer)
            let fetchedBenefits = try context.fetch(descriptor)
            
            let widgetBenefits = fetchedBenefits.prefix(3).map { benefit in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: currentDate, to: benefit.nextResetDate)
                let days = components.day ?? 0
                return WidgetBenefit(
                    name: benefit.name,
                    cardName: benefit.cardName,
                    amount: benefit.amount,
                    daysRemaining: days,
                    isUrgent: days <= 5
                )
            }
            
            let entry = SimpleEntry(date: currentDate, benefits: Array(widgetBenefits))
            completion(entry)
        } catch {
            completion(placeholder(in: context))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let descriptor = FetchDescriptor<CardBenefit>(
            predicate: #Predicate { !$0.isUsed },
            sortBy: [SortDescriptor(\.nextResetDate)]
        )
        
        do {
            let context = ModelContext(modelContainer)
            let fetchedBenefits = try context.fetch(descriptor)
            
            let widgetBenefits = fetchedBenefits.prefix(3).map { benefit in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: currentDate, to: benefit.nextResetDate)
                let days = components.day ?? 0
                return WidgetBenefit(
                    name: benefit.name,
                    cardName: benefit.cardName,
                    amount: benefit.amount,
                    daysRemaining: days,
                    isUrgent: days <= 5
                )
            }
            
            let entry = SimpleEntry(date: currentDate, benefits: Array(widgetBenefits))
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        } catch {
            let entry = SimpleEntry(date: currentDate, benefits: [])
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct WidgetBenefit: Identifiable {
    let id = UUID()
    let name: String
    let cardName: String
    let amount: Double
    let daysRemaining: Int
    let isUrgent: Bool
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let benefits: [WidgetBenefit]
}

struct TrackMyCardWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Upcoming")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            if entry.benefits.isEmpty {
                Spacer()
                Text("All caught up!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                let displayCount = 3
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.benefits.prefix(displayCount)) { benefit in
                        WidgetBenefitRow(benefit: benefit, isCompact: family == .systemSmall)
                        if benefit.id != entry.benefits.prefix(displayCount).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct WidgetBenefitRow: View {
    let benefit: WidgetBenefit
    let isCompact: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(benefit.name)
                    .font(.system(size: isCompact ? 11 : 13, weight: .semibold))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(benefit.amount, format: .currency(code: "USD"))
                    .font(.system(size: isCompact ? 11 : 13, weight: .bold))
                Text(benefit.daysRemaining == 0 ? "Today" : "\(benefit.daysRemaining)d")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(benefit.isUrgent ? .red : .secondary)
            }
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
    SimpleEntry(date: .now, benefits: [
        WidgetBenefit(name: "Uber Cash", cardName: "Amex Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true),
        WidgetBenefit(name: "Dining Credit", cardName: "Amex Gold", amount: 10.0, daysRemaining: 8, isUrgent: false)
    ])
    SimpleEntry(date: .now, benefits: [
        WidgetBenefit(name: "Uber Cash", cardName: "Amex Platinum", amount: 15.0, daysRemaining: 0, isUrgent: true)
    ])
}
