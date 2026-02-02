import SwiftUI
import SwiftData

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userCards: [UserCard]
    
    // Alert state
    @State private var pendingTemplate: CardTemplate?
    @State private var showingAddConfirmation = false
    @State private var showingRemoveConfirmation = false

    var body: some View {
        NavigationStack {
            List(CardPresets.all) { cardTemplate in
                let isOwned = isOwned(cardTemplate)
                
                Section {
                    if isOwned {
                        // Summary view for owned cards
                        Text("✅ You own this card")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                            .listRowBackground(Color.green.opacity(0.1))
                    } else {
                        // Detailed benefit preview for unowned cards
                        ForEach(cardTemplate.benefits) { benefit in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(benefit.name)
                                        .font(.subheadline)
                                    Text(benefit.notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(benefit.amount, format: .currency(code: "USD"))
                                    Text(benefit.period.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(cardTemplate.issuer)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(cardTemplate.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button(isOwned ? "Remove" : "Add") {
                            pendingTemplate = cardTemplate
                            if isOwned {
                                showingRemoveConfirmation = true
                            } else {
                                showingAddConfirmation = true
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(isOwned ? .red : .blue)
                        .controlSize(.small)
                    }
                }
            }
            .navigationTitle("Card Catalog")
            .alert("Add \(pendingTemplate?.name ?? "Card")?", isPresented: $showingAddConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Add Card") {
                    if let template = pendingTemplate {
                        addCard(from: template)
                    }
                }
            } message: {
                Text("This will add \(pendingTemplate?.benefits.count ?? 0) benefits to your tracker.")
            }
            .alert("Remove \(pendingTemplate?.name ?? "Card")?", isPresented: $showingRemoveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    if let template = pendingTemplate {
                        removeCard(from: template)
                    }
                }
            } message: {
                Text("This will remove the card and all its tracked benefits from your list.")
            }
        }
    }

    private func isOwned(_ template: CardTemplate) -> Bool {
        return userCards.contains { $0.name == template.name && $0.issuer == template.issuer }
    }
    
    private func addCard(from template: CardTemplate) {
        // Create UserCard
        let newUserCard = UserCard(name: template.name, issuer: template.issuer)
        modelContext.insert(newUserCard)
        
        // Create Benefits linked to the card
        for benefitTemplate in template.benefits {
            let newBenefit = CardBenefit(
                name: benefitTemplate.name,
                cardName: "\(template.issuer) \(template.name)",
                amount: benefitTemplate.amount,
                period: benefitTemplate.period,
                notes: benefitTemplate.notes
            )
            // Link relationship
            newBenefit.userCard = newUserCard
            // No need to manually insert newBenefit if it's in the relationship and we save? 
            // SwiftData usually handles this if we append to newUserCard.benefits
            // But let's be explicit and insert benefit first or just set the property.
            newUserCard.benefits.append(newBenefit)
        }
        
        // SwiftData autosaves on RunLoop, or we can assume it's done.
    }
    
    private func removeCard(from template: CardTemplate) {
        if let cardToRemove = userCards.first(where: { $0.name == template.name && $0.issuer == template.issuer }) {
            // Delete the card. The cascade rule in UserCard will delete the benefits.
            modelContext.delete(cardToRemove)
        }
    }
}

#Preview {
    AddCardView()
        .modelContainer(for: [UserCard.self, CardBenefit.self], inMemory: true)
}