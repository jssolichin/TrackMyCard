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
    let benefits: [BenefitTemplate]
}

struct CardPresets {
    static let all: [CardTemplate] = [
        CardTemplate(name: "Platinum", benefits: [
            BenefitTemplate(name: "Hotel Credit", amount: 600, period: .semiAnnually, notes: "$300 Jan-Jun and $300 Jul-Dec for FHR/Hotel Collection (prepaid)."),
            BenefitTemplate(name: "Resy Credit", amount: 100, period: .quarterly, notes: "$100 quarterly credit for eligible Resy restaurants ($400/yr)."),
            BenefitTemplate(name: "Lululemon Credit", amount: 75, period: .quarterly, notes: "$75 quarterly credit for in-store or online Lululemon purchases ($300/yr)."),
            BenefitTemplate(name: "Oura Ring Credit", amount: 200, period: .annually, notes: "One-time annual credit toward Oura Ring purchases."),
            BenefitTemplate(name: "Digital Entertainment", amount: 25, period: .monthly, notes: "Disney+, Hulu, ESPN+, Peacock, NYT, WSJ, YouTube Premium ($300/yr)."),
            BenefitTemplate(name: "Uber Cash", amount: 15, period: .monthly, notes: "Rides or Eats. $35 total in Dec ($200/yr)."),
            BenefitTemplate(name: "Uber One Credit", amount: 120, period: .annually, notes: "Statement credit for monthly Uber One membership cost."),
            BenefitTemplate(name: "Airline Fee Credit", amount: 200, period: .annually, notes: "Incidental fees on your selected airline."),
            BenefitTemplate(name: "Saks Fifth Avenue", amount: 50, period: .semiAnnually, notes: "Jan-Jun and Jul-Dec shopping credits ($100/yr)."),
            BenefitTemplate(name: "Equinox Credit", amount: 300, period: .annually, notes: "Credit for Equinox membership or Equinox+ app."),
            BenefitTemplate(name: "CLEAR Plus", amount: 209, period: .annually, notes: "Increased to cover the full $209 annual membership cost."),
            BenefitTemplate(name: "Walmart+ Membership", amount: 13, period: .monthly, notes: "Covers monthly membership cost."),
            BenefitTemplate(name: "Global Entry/TSA PreCheck", amount: 120, period: .everyFourYears, notes: "Statement credit for application fee.")
        ]),
        CardTemplate(name: "Business Platinum", benefits: [
            BenefitTemplate(name: "Hotel Credit", amount: 600, period: .semiAnnually, notes: "$300 Jan-Jun and $300 Jul-Dec for FHR/Hotel Collection (prepaid)."),
            BenefitTemplate(name: "Dell Technologies", amount: 150, period: .annually, notes: "$150 base credit. Spend $5k to unlock $1,000 bonus credit."),
            BenefitTemplate(name: "Adobe Creative Cloud", amount: 250, period: .annually, notes: "Credit requires spending $600+ with Adobe."),
            BenefitTemplate(name: "Indeed Credit", amount: 90, period: .quarterly, notes: "$90 credit per quarter for Indeed services."),
            BenefitTemplate(name: "Wireless Credit", amount: 10, period: .monthly, notes: "$10 monthly credit for US wireless services."),
            BenefitTemplate(name: "Airline Fee Credit", amount: 200, period: .annually, notes: "Incidental fees on your selected airline."),
            BenefitTemplate(name: "CLEAR Plus", amount: 209, period: .annually, notes: "Increased to cover the full $209 annual membership cost."),
            BenefitTemplate(name: "Global Entry/TSA PreCheck", amount: 120, period: .everyFourYears, notes: "Statement credit for application fee.")
        ]),
        CardTemplate(name: "Gold", benefits: [
            BenefitTemplate(name: "Dining Credit", amount: 10, period: .monthly, notes: "Grubhub, Cheesecake Factory, Goldbelly, Wine.com, Five Guys."),
            BenefitTemplate(name: "Uber Cash", amount: 10, period: .monthly, notes: "Rides or Eats ($120/yr total)."),
            BenefitTemplate(name: "Resy Credit", amount: 50, period: .semiAnnually, notes: "Jan-Jun and Jul-Dec credits for Resy restaurants."),
            BenefitTemplate(name: "Dunkin' Credit", amount: 7, period: .monthly, notes: "Monthly credit for Dunkin' locations.")
        ]),
        CardTemplate(name: "Preferred", benefits: [
            BenefitTemplate(name: "Chase Travel Hotel", amount: 50, period: .annually, notes: "Annual credit for hotel stays booked through Chase.")
        ]),
        CardTemplate(name: "Reserve", benefits: [
            BenefitTemplate(name: "Annual Travel Credit", amount: 300, period: .annually, notes: "Reimbursement for any travel purchases."),
            BenefitTemplate(name: "Exclusive Tables Dining", amount: 150, period: .semiAnnually, notes: "For bookings via Sapphire Exclusive Tables ($300/yr)."),
            BenefitTemplate(name: "StubHub Credit", amount: 150, period: .semiAnnually, notes: "Credit for StubHub purchases ($300/yr)."),
            BenefitTemplate(name: "DoorDash Credit", amount: 25, period: .monthly, notes: "$5 restaurant promo + two $10 grocery/retail promos monthly."),
            BenefitTemplate(name: "Apple TV/Music", amount: 24, period: .monthly, notes: "Credits for Apple TV+ and Apple Music subscriptions ($288/yr value)."),
            BenefitTemplate(name: "Lyft Credit", amount: 10, period: .monthly, notes: "Monthly credit for Lyft rides."),
            BenefitTemplate(name: "Peloton Credit", amount: 10, period: .monthly, notes: "Monthly credit for Peloton membership/equipment.")
        ]),
        CardTemplate(name: "Venture", benefits: [
            BenefitTemplate(name: "Lifestyle Hotel Credit", amount: 50, period: .annually, notes: "For hotels in the Lifestyle Collection booked via Capital One."),
            BenefitTemplate(name: "Global Entry/TSA PreCheck", amount: 120, period: .everyFourYears, notes: "Statement credit for application fees.")
        ]),
        CardTemplate(name: "Venture X", benefits: [
            BenefitTemplate(name: "Annual Travel Credit", amount: 300, period: .annually, notes: "For bookings through Capital One Travel."),
            BenefitTemplate(name: "Anniversary Bonus", amount: 100, period: .annually, notes: "10,000 bonus miles (worth ~$100) every anniversary."),
            BenefitTemplate(name: "Global Entry/TSA PreCheck", amount: 120, period: .everyFourYears, notes: "Statement credit for application fees."),
            BenefitTemplate(name: "Lounge Guest Policy", amount: 0, period: .annually, notes: "As of Feb 1, 2026: No free guests unless $75k annual spend.")
        ])
    ]
}
