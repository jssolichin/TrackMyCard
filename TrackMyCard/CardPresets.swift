import Foundation

struct BenefitTemplate: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let period: BenefitPeriod
    let notes: String
}

struct CardTemplate: Identifiable {
    let id = UUID()
    let name: String
    let issuer: String
    let benefits: [BenefitTemplate]
}

struct CardPresets {
    static let all: [CardTemplate] = [
        CardTemplate(name: "Platinum Card®", issuer: "American Express", benefits: [
            BenefitTemplate(name: "Hotel Credit", amount: 300, period: .semiAnnually, notes: "Prepaid Fine Hotels + Resorts or The Hotel Collection bookings via Amex Travel."),
            BenefitTemplate(name: "Resy Credit", amount: 100, period: .quarterly, notes: "Eligible purchases at Resy restaurants."),
            BenefitTemplate(name: "Digital Entertainment", amount: 25, period: .monthly, notes: "Disney+, Hulu, ESPN+, NYT, Peacock, WSJ, etc."),
            BenefitTemplate(name: "Uber Cash", amount: 15, period: .monthly, notes: "Rides or Eats. Bonus in December."),
            BenefitTemplate(name: "Airline Fee Credit", amount: 200, period: .annually, notes: "Incidental fees on selected airline."),
            BenefitTemplate(name: "Saks Fifth Avenue", amount: 50, period: .semiAnnually, notes: "Jan-Jun and Jul-Dec."),
            BenefitTemplate(name: "Walmart+ Credit", amount: 12.95, period: .monthly, notes: "Covers monthly membership cost.")
        ]),
        CardTemplate(name: "Gold Card®", issuer: "American Express", benefits: [
            BenefitTemplate(name: "Dining Credit", amount: 10, period: .monthly, notes: "Grubhub, Cheesecake Factory, Goldbelly, Wine.com, Five Guys."),
            BenefitTemplate(name: "Uber Cash", amount: 10, period: .monthly, notes: "Rides or Eats."),
            BenefitTemplate(name: "Resy Credit", amount: 50, period: .semiAnnually, notes: "Eligible U.S. Resy restaurants."),
            BenefitTemplate(name: "Dunkin' Credit", amount: 7, period: .monthly, notes: "U.S. Dunkin' locations.")
        ]),
        CardTemplate(name: "Sapphire Preferred®", issuer: "Chase", benefits: [
            BenefitTemplate(name: "Hotel Credit", amount: 50, period: .annually, notes: "Annually for hotel stays purchased through Chase Travel.")
        ]),
        CardTemplate(name: "Sapphire Reserve®", issuer: "Chase", benefits: [
            BenefitTemplate(name: "Travel Credit", amount: 300, period: .annually, notes: "Reimbursement for travel purchases."),
            BenefitTemplate(name: "DoorDash", amount: 5, period: .monthly, notes: "Monthly DoorDash credits (check current terms).")
        ]),
        CardTemplate(name: "Venture®", issuer: "Capital One", benefits: [
            BenefitTemplate(name: "Global Entry / TSA PreCheck", amount: 120, period: .everyFourYears, notes: "Statement credit for application fee."),
            BenefitTemplate(name: "Hotel Credit", amount: 50, period: .annually, notes: "Annually for hotel stays purchased through CapitalOne Travel.")
        ]),
        CardTemplate(name: "Venture X®", issuer: "Capital One", benefits: [
            BenefitTemplate(name: "Annual Travel Credit", amount: 300, period: .annually, notes: "For bookings through Capital One Travel."),
            BenefitTemplate(name: "Anniversary Bonus", amount: 100, period: .annually, notes: "10,000 bonus miles every year."),
            BenefitTemplate(name: "Global Entry / TSA PreCheck", amount: 100, period: .everyFourYears, notes: "Statement credit for application fee.")
        ])
    ]
}
