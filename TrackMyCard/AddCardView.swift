import SwiftUI
import SwiftData
import WidgetKit

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userCards: [UserCard]
    
    @State private var showingCustomCardSheet = false
    @State private var editingCard: UserCard?
    @State private var pendingTemplate: CardTemplate?
    @State private var showingAddConfirmation = false
    @State private var showingRemoveConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if !userCards.isEmpty {
                    Section("My Cards") {
                        ForEach(userCards) { card in
                            Button {
                                editingCard = card
                            } label: {
                                HStack {
                                    CardIconView(cardName: card.name, size: 24)
                                    VStack(alignment: .leading) {
                                        Text(card.name)
                                            .font(.headline)
                                        Text("\(card.benefits.count) benefits")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "pencil.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteCards)
                    }
                }
                
                Section {
                    Button(action: { showingCustomCardSheet = true }) {
                        Label("Add Custom Card", systemImage: "plus.circle.fill")
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Catalog") {
                    ForEach(CardPresets.all) { cardTemplate in
                        let count = ownedCount(cardTemplate)
                        let isOwned = count > 0
                        
                        DisclosureGroup {
                            ForEach(cardTemplate.benefits.sorted { $0.amount > $1.amount }) { benefit in
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
                                .padding(.vertical, 2)
                            }
                            
                            Button(isOwned ? "Add Another" : "Add This Card") {
                                pendingTemplate = cardTemplate
                                showingAddConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.vertical, 8)
                        } label: {
                            HStack(spacing: 12) {
                                CardIconView(cardName: cardTemplate.name, size: 16)
                                Text(cardTemplate.name)
                                    .font(.headline)
                                if isOwned {
                                    Spacer()
                                    Text(count > 1 ? "\(count) Added" : "Added")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.green.opacity(0.2))
                                        .foregroundStyle(.green)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Text("Benefits and terms can change. Please verify the most up-to-date information.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Manage Cards")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showingCustomCardSheet) {
                EditCardView(card: nil)
            }
            .sheet(item: $editingCard) { card in
                EditCardView(card: card)
            }
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
        }
    }

    private func ownedCount(_ template: CardTemplate) -> Int {
        return userCards.filter { $0.name == template.name }.count
    }
    
    private func addCard(from template: CardTemplate) {
        let newUserCard = UserCard(name: template.name)
        modelContext.insert(newUserCard)
        
        for benefitTemplate in template.benefits {
            let newBenefit = CardBenefit(
                name: benefitTemplate.name,
                cardName: template.name,
                amount: benefitTemplate.amount,
                period: benefitTemplate.period,
                notes: benefitTemplate.notes
            )
            newBenefit.userCard = newUserCard
            newUserCard.benefits.append(newBenefit)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
        private func deleteCards(at offsets: IndexSet) {
    
            for index in offsets {
    
                modelContext.delete(userCards[index])
    
            }
    
            WidgetCenter.shared.reloadAllTimelines()
    
        }
    
    }
    
    
    
    #Preview {
    
        AddCardView()
    
            .modelContainer(for: [UserCard.self, CardBenefit.self], inMemory: true)
    
    }
    
    