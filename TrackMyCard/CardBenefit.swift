import SwiftUI
import SwiftData
import Foundation

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
    var lastUpdated: Date?
    var notes: String
    var userCard: UserCard?
    
    init(name: String, cardName: String, amount: Double, period: BenefitPeriod, nextResetDate: Date = Date(), isUsed: Bool = false, lastUpdated: Date? = nil, notes: String = "") {
        self.name = name
        self.cardName = cardName
        self.amount = amount
        self.period = period
        self.nextResetDate = nextResetDate
        self.isUsed = isUsed
        self.lastUpdated = lastUpdated
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
            lastUpdated = now // Track reset as an update
            
            // Advance date to the start of the next calendar period
            switch period {
            case .monthly:
                // Move to the 1st of the next month
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: nextResetDate),
                   let startOfNextMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)) {
                    nextResetDate = startOfNextMonth
                }
            case .quarterly:
                // Quarterly usually means Jan-Mar, Apr-Jun, etc. 
                // But for simplicity of "every 3 months from start", let's just do 3 months.
                // If the user wants "Calendar Quarter", we might need to align to Jan 1, Apr 1, Jul 1, Oct 1.
                // Let's assume standard calendar quarters.
                let month = calendar.component(.month, from: nextResetDate)
                let quarters = [1, 4, 7, 10]
                let currentQuarterStartMonth = quarters.last(where: { $0 <= month }) ?? 1
                if let currentQuarterStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextResetDate), month: currentQuarterStartMonth)),
                   let nextQuarterStart = calendar.date(byAdding: .month, value: 3, to: currentQuarterStart) {
                    nextResetDate = nextQuarterStart
                }
            case .semiAnnually:
                // Align to Jan 1 or Jul 1
                let month = calendar.component(.month, from: nextResetDate)
                let semiStartMonth = month <= 6 ? 1 : 7
                if let currentSemiStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextResetDate), month: semiStartMonth)),
                   let nextSemiStart = calendar.date(byAdding: .month, value: 6, to: currentSemiStart) {
                    nextResetDate = nextSemiStart
                }
            case .annually:
                // Move to Jan 1 of the next year
                if let nextYear = calendar.date(byAdding: .year, value: 1, to: nextResetDate),
                   let startOfNextYear = calendar.date(from: calendar.dateComponents([.year], from: nextYear)) {
                    nextResetDate = startOfNextYear
                }
            case .everyFourYears:
                if let next = calendar.date(byAdding: .year, value: 4, to: nextResetDate),
                   let startOfPeriod = calendar.date(from: calendar.dateComponents([.year], from: next)) {
                    nextResetDate = startOfPeriod
                }
            }
            
            // Safety break
            if nextResetDate < now.addingTimeInterval(-365*24*60*60 * 10) { 
                 nextResetDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
                 break 
            }
        }
    }
}
