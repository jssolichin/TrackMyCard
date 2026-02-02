import Foundation
import SwiftData

enum BenefitPeriod: String, Codable, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case annually = "Annually"
    case everyFourYears = "Every 4 Years"
    
    var id: Self { self }
}

@Model
final class CardBenefit {
    var name: String
    var cardName: String
    var amount: Double
    var period: BenefitPeriod
    var nextResetDate: Date
    var isUsed: Bool
    var notes: String
    var userCard: UserCard?
    
    init(name: String, cardName: String, amount: Double, period: BenefitPeriod, nextResetDate: Date = Date(), isUsed: Bool = false, notes: String = "") {
        self.name = name
        self.cardName = cardName
        self.amount = amount
        self.period = period
        self.nextResetDate = nextResetDate
        self.isUsed = isUsed
        self.notes = notes
    }
}

extension CardBenefit {
    func checkAndReset() {
        let calendar = Calendar.current
        let now = Date()
        
        while nextResetDate < now {
            // Reset usage
            isUsed = false
            
            // Advance date
            switch period {
            case .monthly:
                if let next = calendar.date(byAdding: .month, value: 1, to: nextResetDate) {
                    nextResetDate = next
                }
            case .quarterly:
                if let next = calendar.date(byAdding: .month, value: 3, to: nextResetDate) {
                    nextResetDate = next
                }
            case .semiAnnually:
                if let next = calendar.date(byAdding: .month, value: 6, to: nextResetDate) {
                    nextResetDate = next
                }
            case .annually:
                if let next = calendar.date(byAdding: .year, value: 1, to: nextResetDate) {
                    nextResetDate = next
                }
            case .everyFourYears:
                if let next = calendar.date(byAdding: .year, value: 4, to: nextResetDate) {
                    nextResetDate = next
                }
            }
            
            // Safety break to prevent infinite loops if something goes wrong with date calc (though unlikely with standard calendar)
            if nextResetDate < now.addingTimeInterval(-365*24*60*60 * 10) { 
                 // If date is WAY in the past (e.g. 10 years), just set to now + period to catch up.
                 // Ideally we'd calculate strictly, but this avoids infinite loops in edge cases.
                 nextResetDate = now
                 break 
            }
        }
    }
}
