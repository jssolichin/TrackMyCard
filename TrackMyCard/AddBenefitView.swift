import SwiftUI

struct AddBenefitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var cardName: String = ""
    @State private var amount: Double = 0.0
    @State private var period: BenefitPeriod = .monthly
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Benefit Details")) {
                    TextField("Benefit Name (e.g. Uber Cash)", text: $name)
                    TextField("Card Name (e.g. Amex Platinum)", text: $cardName)
                    TextField("Amount", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Frequency")) {
                    Picker("Reset Frequency", selection: $period) {
                        ForEach(BenefitPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Optional notes...", text: $notes)
                }
            }
            .navigationTitle("Add Benefit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBenefit()
                    }
                    .disabled(name.isEmpty || cardName.isEmpty)
                }
            }
        }
    }

    private func saveBenefit() {
        let newBenefit = CardBenefit(
            name: name,
            cardName: cardName,
            amount: amount,
            period: period,
            notes: notes
        )
        modelContext.insert(newBenefit)
        dismiss()
    }
}

#Preview {
    AddBenefitView()
}
