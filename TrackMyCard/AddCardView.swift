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

struct EditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var benefits: [BenefitEditModel]
    
    var existingCard: UserCard?
    
    init(card: UserCard?) {
        self.existingCard = card
        _name = State(initialValue: card?.name ?? "")
        _benefits = State(initialValue: card?.benefits.map { BenefitEditModel(benefit: $0) } ?? [])
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Card Details") {
                    TextField("Card Name", text: $name)
                }
                
                let activeIndices = benefits.indices.filter { !benefits[$0].isHidden }
                Section("Active Benefits") {
                    ForEach(activeIndices, id: \.self) { index in
                        benefitRow(for: $benefits[index])
                    }
                    .onDelete { indexSet in
                        let indicesToRemove = indexSet.map { activeIndices[$0] }
                        for index in indicesToRemove.sorted(by: >) {
                            benefits.remove(at: index)
                        }
                    }
                    
                    Button {
                        benefits.append(BenefitEditModel(name: "", amount: 0, period: .monthly, notes: ""))
                    } label: {
                        Label("Add Benefit", systemImage: "plus.circle")
                    }
                }
                
                let hiddenIndices = benefits.indices.filter { benefits[$0].isHidden }
                if !hiddenIndices.isEmpty {
                    Section("Hidden Benefits") {
                        ForEach(hiddenIndices, id: \.self) { index in
                            benefitRow(for: $benefits[index])
                        }
                        .onDelete { indexSet in
                            let indicesToRemove = indexSet.map { hiddenIndices[$0] }
                            for index in indicesToRemove.sorted(by: >) {
                                benefits.remove(at: index)
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingCard == nil ? "New Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    @ViewBuilder
    private func benefitRow(for benefit: Binding<BenefitEditModel>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Benefit Name", text: benefit.name)
                    .font(.headline)
                Spacer()
                Button {
                    benefit.isHidden.wrappedValue.toggle()
                } label: {
                    Image(systemName: benefit.isHidden.wrappedValue ? "eye" : "eye.slash")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            HStack {
                TextField("Amount", value: benefit.amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                Picker("", selection: benefit.period) {
                    ForEach(BenefitPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
            }
            TextField("Notes", text: benefit.notes)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func save() {
        if let card = existingCard {
            card.name = name
            
            // Remove benefits not in the edit list
            let benefitIdsToKeep = Set(benefits.compactMap { $0.id })
            for benefit in card.benefits {
                if !benefitIdsToKeep.contains(benefit.id) {
                    modelContext.delete(benefit)
                }
            }
            
            // Update or add benefits
            for editModel in benefits {
                if let existingBenefit = card.benefits.first(where: { $0.id == editModel.id }) {
                    existingBenefit.name = editModel.name
                    existingBenefit.amount = editModel.amount
                    existingBenefit.period = editModel.period
                    existingBenefit.notes = editModel.notes
                    existingBenefit.isHidden = editModel.isHidden
                } else {
                    let newBenefit = CardBenefit(
                        name: editModel.name,
                        cardName: name,
                        amount: editModel.amount,
                        period: editModel.period,
                        notes: editModel.notes,
                        isHidden: editModel.isHidden
                    )
                    newBenefit.userCard = card
                    card.benefits.append(newBenefit)
                }
            }
        } else {
            let newCard = UserCard(name: name)
            modelContext.insert(newCard)
            for editModel in benefits {
                let newBenefit = CardBenefit(
                    name: editModel.name,
                    cardName: name,
                    amount: editModel.amount,
                    period: editModel.period,
                    notes: editModel.notes,
                    isHidden: editModel.isHidden
                )
                newBenefit.userCard = newCard
                newCard.benefits.append(newBenefit)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct BenefitEditModel: Identifiable {
    var id: PersistentIdentifier?
    var name: String
    var amount: Double
    var period: BenefitPeriod
    var notes: String
    var isHidden: Bool
    
    init(benefit: CardBenefit) {
        self.id = benefit.persistentModelID
        self.name = benefit.name
        self.amount = benefit.amount
        self.period = benefit.period
        self.notes = benefit.notes
        self.isHidden = benefit.isHidden ?? false
    }
    
    init(name: String, amount: Double, period: BenefitPeriod, notes: String, isHidden: Bool = false) {
        self.id = nil
        self.name = name
        self.amount = amount
        self.period = period
        self.notes = notes
        self.isHidden = isHidden
    }
}


#Preview {
    AddCardView()
        .modelContainer(for: [UserCard.self, CardBenefit.self], inMemory: true)
}