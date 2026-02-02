import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CardBenefit.nextResetDate, order: .forward) private var benefits: [CardBenefit]
    @State private var showingAddSheet = false

    var availableBenefits: [CardBenefit] {
        benefits.filter { !$0.isUsed }
    }
    
    var usedBenefits: [CardBenefit] {
        benefits.filter { $0.isUsed }
    }

    var body: some View {
        NavigationStack {
            List {
                if !availableBenefits.isEmpty {
                    Section(header: Text("Available")) {
                        ForEach(availableBenefits) { benefit in
                            BenefitRow(benefit: benefit)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(availableBenefits[index])
                            }
                        }
                    }
                }
                
                if !usedBenefits.isEmpty {
                    Section(header: Text("Used")) {
                        ForEach(usedBenefits) { benefit in
                            BenefitRow(benefit: benefit)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(usedBenefits[index])
                            }
                        }
                    }
                }
                
                if benefits.isEmpty {
                    ContentUnavailableView("No Benefits Tracked", systemImage: "creditcard.and.123", description: Text("Add your credit card benefits to start tracking."))
                }
            }
            .navigationTitle("My Benefits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Benefit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBenefitView()
            }
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

struct BenefitRow: View {
    @Bindable var benefit: CardBenefit
    
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(benefit.name)
                    .font(.headline)
                Text("\(benefit.cardName) • \(benefit.period.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !benefit.notes.isEmpty {
                    Text(benefit.notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(benefit.amount, format: .currency(code: "USD"))
                    .fontWeight(.bold)
                
                if benefit.isUsed {
                    Text("Resets \(benefit.nextResetDate, format: .dateTime.month().day())")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    // Available: Show urgency
                    Text(daysRemaining == 0 ? "Ends Today" : "Ends in \(daysRemaining)d")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(urgencyColor)
                }
            }
            
            Button {
                withAnimation {
                    benefit.isUsed.toggle()
                }
            } label: {
                Image(systemName: benefit.isUsed ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(benefit.isUsed ? .green : .gray)
            }
            .buttonStyle(.plain) // Important for List row clicks
            .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [CardBenefit.self, UserCard.self], inMemory: true)
}
