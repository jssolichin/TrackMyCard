import SwiftUI

struct CardIconView: View {
    let cardName: String
    var size: CGFloat = 24
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(CardTheme.iconColor(for: cardName).gradient)
                .frame(width: size * 1.4, height: size)
            
            Text(cardName.prefix(1).uppercased())
                .font(.system(size: size * 0.6, weight: .bold))
                .foregroundColor(CardTheme.labelColor(for: cardName))
        }
    }
}
