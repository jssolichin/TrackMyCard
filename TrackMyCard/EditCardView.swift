import SwiftUI
import SwiftData
import WidgetKit

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
