import SwiftUI
import SwiftData
import WidgetKit

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CardBenefit.nextResetDate, order: .forward) private var benefits: [CardBenefit]
    @State private var showingAddSheet = false
    @State private var expandedGroups: Set<String> = []

    var availableBenefits: [CardBenefit] {
        benefits.filter { !$0.isUsed && !($0.isHidden ?? false) }
    }
    
    var usedBenefits: [CardBenefit] {
        benefits.filter { $0.isUsed && !($0.isHidden ?? false) }
    }
    
    private func groupedBenefits(_ benefits: [CardBenefit]) -> [BenefitGroup] {
        let groups = Dictionary(grouping: benefits, by: { $0.name })
        return groups.map { BenefitGroup(name: $0.key, benefits: $0.value) }
            .sorted { 
                if $0.earliestResetDate != $1.earliestResetDate {
                    return $0.earliestResetDate < $1.earliestResetDate
                }
                return $0.name < $1.name
            }
    }

    var body: some View {
        NavigationStack {
            List {
                if !availableBenefits.isEmpty {
                    Section(header: Text("Available")) {
                        let groups = groupedBenefits(availableBenefits)
                        ForEach(groups) { group in
                            Group {
                                if group.benefits.count > 1 {
                                    VStack(alignment: .leading, spacing: 0) {
                                        BenefitGroupSummaryRow(group: group, isExpanded: expandedGroups.contains(group.id)) {
                                            if expandedGroups.contains(group.id) {
                                                expandedGroups.remove(group.id)
                                            } else {
                                                expandedGroups.insert(group.id)
                                            }
                                        }
                                        
                                        if expandedGroups.contains(group.id) {
                                            ForEach(group.benefits.sorted { $0.nextResetDate < $1.nextResetDate }) { benefit in
                                                BenefitRow(benefit: benefit, isChild: true)
                                                    .padding(.leading, 10)
                                                    .swipeActions(edge: .trailing) {
                                                        Button {
                                                            benefit.isHidden = true
                                                            try? modelContext.save()
                                                            WidgetCenter.shared.reloadAllTimelines()
                                                        } label: {
                                                            Label("Hide", systemImage: "eye.slash")
                                                        }
                                                        .tint(.gray)
                                                    }
                                            }
                                        }
                                    }
                                } else {
                                    BenefitRow(benefit: group.benefits[0])
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    for benefit in group.benefits {
                                        benefit.isHidden = true
                                    }
                                    try? modelContext.save()
                                    WidgetCenter.shared.reloadAllTimelines()
                                } label: {
                                    Label("Hide", systemImage: "eye.slash")
                                }
                                .tint(.gray)
                            }
                        }
                    }
                }
                
                if !usedBenefits.isEmpty {
                    Section(header: Text("Used")) {
                        let groups = groupedBenefits(usedBenefits)
                        ForEach(groups) { group in
                            Group {
                                if group.benefits.count > 1 {
                                    VStack(alignment: .leading, spacing: 0) {
                                        BenefitGroupSummaryRow(group: group, isExpanded: expandedGroups.contains(group.id)) {
                                            if expandedGroups.contains(group.id) {
                                                expandedGroups.remove(group.id)
                                            } else {
                                                expandedGroups.insert(group.id)
                                            }
                                        }
                                        
                                        if expandedGroups.contains(group.id) {
                                            ForEach(group.benefits.sorted { $0.nextResetDate < $1.nextResetDate }) { benefit in
                                                BenefitRow(benefit: benefit, isChild: true)
                                                    .padding(.leading, 10)
                                                    .swipeActions(edge: .trailing) {
                                                        Button {
                                                            benefit.isHidden = true
                                                            try? modelContext.save()
                                                            WidgetCenter.shared.reloadAllTimelines()
                                                        } label: {
                                                            Label("Hide", systemImage: "eye.slash")
                                                        }
                                                        .tint(.gray)
                                                    }
                                            }
                                        }
                                    }
                                } else {
                                    BenefitRow(benefit: group.benefits[0])
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    for benefit in group.benefits {
                                        benefit.isHidden = true
                                    }
                                    try? modelContext.save()
                                    WidgetCenter.shared.reloadAllTimelines()
                                } label: {
                                    Label("Hide", systemImage: "eye.slash")
                                }
                                .tint(.gray)
                            }
                        }
                    }
                }
                
                if benefits.isEmpty {
                    ContentUnavailableView("No Benefits Tracked", systemImage: "creditcard.and.123", description: Text("Go to the Cards tab to add cards from the catalog or create your own custom card!"))
                }
            }
            .navigationTitle("My Benefits")
            .onAppear {
                refreshBenefits()
            }
        }
    }
    
    private func refreshBenefits() {
        // Check for resets
        for benefit in benefits {
            benefit.checkAndReset()
        }
    }
}

struct BenefitGroup: Identifiable {
    let name: String
    let benefits: [CardBenefit]
    var id: String { name }
    
    var totalAmount: Double {
        benefits.reduce(0) { $0 + $1.amount }
    }
    
    var earliestResetDate: Date {
        benefits.map { $0.nextResetDate }.min() ?? Date()
    }
    
    var isAllUsed: Bool {
        benefits.allSatisfy { $0.isUsed }
    }
}

struct BenefitGroupSummaryRow: View {
    @Environment(\.modelContext) private var modelContext
    let group: BenefitGroup
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                HStack(spacing: 6) {
                    HStack(spacing: -4) {
                        // Get unique physical cards or unique benefit sources
                        let displayItems: [(id: PersistentIdentifier, name: String)] = {
                            var items: [(id: PersistentIdentifier, name: String)] = []
                            var seenCardIDs = Set<PersistentIdentifier>()
                            
                            for benefit in group.benefits {
                                if let card = benefit.userCard {
                                    if !seenCardIDs.contains(card.persistentModelID) {
                                        seenCardIDs.insert(card.persistentModelID)
                                        items.append((id: card.persistentModelID, name: card.name))
                                    }
                                } else {
                                    // Standalone benefit without a card
                                    items.append((id: benefit.persistentModelID, name: benefit.cardName))
                                }
                            }
                            return Array(items.prefix(5))
                        }()

                        ForEach(displayItems, id: \.id) { item in
                            CardIconView(cardName: item.name, size: 14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(.background, lineWidth: 1)
                                )
                        }
                    }
                    .frame(minWidth: 40, alignment: .leading)
                    
                    Text("\(group.benefits.count) items")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(group.totalAmount, format: .currency(code: "USD"))
                    .fontWeight(.bold)
                
                Button {
                    let targetState = !group.isAllUsed
                    withAnimation {
                        for benefit in group.benefits {
                            benefit.isUsed = targetState
                        }
                    }
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                } label: {
                    Image(systemName: group.isAllUsed ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(group.isAllUsed ? .green : .gray)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                onToggleExpand()
            }
        }
        .padding(.vertical, 4)
    }
}

struct BenefitRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var benefit: CardBenefit
    var isChild: Bool = false
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: benefit.nextResetDate)
        return components.day ?? 0
    }
    
    var urgencyColor: Color {
        if benefit.isUsed { return .secondary }
        return daysRemaining <= 5 ? .red : (daysRemaining <= 10 ? .orange : .secondary)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if !isChild {
                    Text(benefit.name)
                        .font(.headline)
                }
                
                if !benefit.notes.isEmpty {
                    Text(benefit.notes)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    CardIconView(cardName: benefit.userCard?.name ?? benefit.cardName, size: 14)
                    
                    Text(benefit.period.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(benefit.amount, format: .currency(code: "USD"))
                    .fontWeight(isChild ? .semibold : .bold)
                
                HStack(spacing: 8) {
                    if benefit.isUsed {
                        Text("Resets \(benefit.nextResetDate, format: .dateTime.month().day())")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(daysRemaining == 0 ? "Today" : "\(daysRemaining)d")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundStyle(urgencyColor)
                    }
                    
                    Button {
                        withAnimation {
                            benefit.isUsed.toggle()
                        }
                        try? modelContext.save()
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Image(systemName: benefit.isUsed ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(benefit.isUsed ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    DashboardView()
        .modelContainer(for: [CardBenefit.self, UserCard.self], inMemory: true)
}
