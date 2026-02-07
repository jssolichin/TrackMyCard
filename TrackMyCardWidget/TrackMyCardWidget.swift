import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// Helper to pass PersistentIdentifier as String
fileprivate extension PersistentIdentifier {
    var widgetID: String {
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        return data.base64EncodedString()
    }
}

struct Provider: TimelineProvider {
    // We create a ModelContainer for the widget's context
    let modelContainer = SharedModelContainer.create()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), benefits: [
            WidgetBenefit(id: "1", name: "Uber Cash", cardName: "Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true, isUsed: false),
            WidgetBenefit(id: "2", name: "Grubhub/Dining Credit", cardName: "Gold", amount: 10.0, daysRemaining: 8, isUrgent: false, isUsed: false),
            WidgetBenefit(id: "3", name: "Chase Travel Hotel", cardName: "Preferred", amount: 50.0, daysRemaining: 12, isUrgent: false, isUsed: false),
            WidgetBenefit(id: "4", name: "Saks Fifth Avenue", cardName: "Platinum", amount: 50.0, daysRemaining: 15, isUrgent: false, isUsed: false)
        ])
    }

    private func fetchBenefits(for date: Date) -> [WidgetBenefit] {
        let descriptor = FetchDescriptor<CardBenefit>(
            sortBy: [SortDescriptor(\.nextResetDate)]
        )
        
        do {
            let context = ModelContext(modelContainer)
            let allBenefits = try context.fetch(descriptor)
            
            // Filter: (Not hidden) AND (Not used OR (Used and updated recently))
            let filteredBenefits = allBenefits.filter { benefit in
                if benefit.isHidden ?? false { return false }
                if !benefit.isUsed { return true }
                if let lastUpdated = benefit.lastUpdated {
                    return date.timeIntervalSince(lastUpdated) < 1.5
                }
                return false
            }
            
            return filteredBenefits.prefix(10).map { benefit in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: date, to: benefit.nextResetDate)
                let days = components.day ?? 0
                return WidgetBenefit(
                    id: benefit.persistentModelID.widgetID,
                    name: benefit.name,
                    cardName: benefit.userCard?.name ?? benefit.cardName,
                    amount: benefit.amount,
                    daysRemaining: days,
                    isUrgent: days <= 5,
                    isUsed: benefit.isUsed
                )
            }
        } catch {
            return []
        }
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let currentDate = Date()
        let benefits = fetchBenefits(for: currentDate)
        let entry = SimpleEntry(date: currentDate, benefits: benefits)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let benefits = fetchBenefits(for: currentDate)
        let entry = SimpleEntry(date: currentDate, benefits: benefits)
        
        // If we have any "recently used" items, we want to refresh quickly to remove them
        let hasRecentlyUsed = benefits.contains { $0.isUsed }
        let nextUpdate = hasRecentlyUsed ? currentDate.addingTimeInterval(1.5) : Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct WidgetBenefit: Identifiable {
    let id: String
    let name: String
    let cardName: String
    let amount: Double
    let daysRemaining: Int
    let isUrgent: Bool
    let isUsed: Bool
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let benefits: [WidgetBenefit]
}

struct ToggleBenefitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Benefit Usage"
    static var description = IntentDescription("Marks a benefit as used.")

    @Parameter(title: "Benefit ID")
    var id: String

    init() {}
    init(id: String) {
        self.id = id
    }

    func perform() async throws -> some IntentResult {
        let container = SharedModelContainer.create()
        let context = ModelContext(container)
        
        guard let data = Data(base64Encoded: id),
              let modelID = try? JSONDecoder().decode(PersistentIdentifier.self, from: data),
              let benefit = context.model(for: modelID) as? CardBenefit else {
            return .result()
        }
        
        benefit.isUsed = true
        benefit.lastUpdated = Date()
        try? context.save()
        
        // Refresh the widget
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

struct TrackMyCardWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let isSmall = family == .systemSmall
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Upcoming")
                    .font(.system(size: isSmall ? 9 : 10, weight: .bold))
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
                let displayCount = 4
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.benefits.prefix(displayCount)) { benefit in
                        WidgetBenefitRow(benefit: benefit, isCompact: isSmall)
                        if benefit.id != entry.benefits.prefix(displayCount).last?.id {
                            Divider()
                                .opacity(isSmall ? 0.5 : 0.7)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.top, isSmall ? 8 : 12)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct WidgetBenefitRow: View {
    let benefit: WidgetBenefit
    let isCompact: Bool
    
    var body: some View {
        HStack(spacing: isCompact ? 6 : 8) {
            // Checkbox on the left
            if benefit.isUsed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
            } else {
                Button(intent: ToggleBenefitIntent(id: benefit.id)) {
                    Image(systemName: "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            if !isCompact {
                CardIconView(cardName: benefit.cardName, size: 12)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(benefit.name)
                    .font(.system(size: isCompact ? 10 : 12, weight: .semibold))
                    .lineLimit(1)
                    .strikethrough(benefit.isUsed)
            }
            
            Spacer(minLength: 4)
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(benefit.amount, format: .currency(code: "USD"))
                    .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                    .foregroundStyle(benefit.isUsed ? .secondary : .primary)
                
                if !benefit.isUsed {
                    Text(benefit.daysRemaining == 0 ? "Today" : "\(benefit.daysRemaining)d")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(benefit.isUrgent ? .red : .secondary)
                }
            }
        }
        .padding(.vertical, isCompact ? 2 : 0)
    }
}

struct TrackMyCardWidget: Widget {
    let kind: String = "TrackMyCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TrackMyCardEntryView(entry: entry)
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
        WidgetBenefit(id: "1", name: "Uber Cash", cardName: "Platinum", amount: 15.0, daysRemaining: 3, isUrgent: true, isUsed: false),
        WidgetBenefit(id: "2", name: "Grubhub Credit", cardName: "Gold", amount: 10.0, daysRemaining: 8, isUrgent: false, isUsed: false)
    ])
    SimpleEntry(date: .now, benefits: [
        WidgetBenefit(id: "1", name: "Uber Cash", cardName: "Platinum", amount: 15.0, daysRemaining: 0, isUrgent: true, isUsed: true)
    ])
}
