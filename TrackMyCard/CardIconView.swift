import SwiftUI

struct CardIconView: View {
    let cardName: String
    let issuer: String?
    var size: CGFloat = 24
    
    var iconColor: Color {
        let name = cardName.lowercased()
        if name.contains("platinum") { return Color(white: 0.85) }
        if name.contains("gold") { return Color(red: 0.83, green: 0.69, blue: 0.22) }
        if name.contains("sapphire reserve") { return Color(red: 0.04, green: 0.15, blue: 0.4) }
        if name.contains("sapphire") { return Color(red: 0.2, green: 0.45, blue: 0.75) }
        if name.contains("venture x") { return Color(red: 0.55, green: 0.1, blue: 0.1) }
        if name.contains("venture") { return Color(red: 0.75, green: 0.35, blue: 0.35) }
        
        let issuerName = (issuer ?? "").lowercased()
        if issuerName.contains("american express") || issuerName.contains("amex") { return .blue }
        if issuerName.contains("chase") { return .indigo }
        if issuerName.contains("capital one") { return .red }
        if issuerName.contains("apple") { return .gray }
        return .orange
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(iconColor.gradient)
                .frame(width: size * 1.4, height: size)
            
            Text(cardName.prefix(1).uppercased())
                .font(.system(size: size * 0.6, weight: .bold))
                .foregroundColor(cardName.lowercased().contains("platinum") ? .black.opacity(0.6) : .white)
        }
    }
}
