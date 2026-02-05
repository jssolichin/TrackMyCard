import SwiftUI

struct CardTheme {
    static func iconColor(for cardName: String) -> Color {
        let name = cardName.lowercased()
        if name.contains("platinum") { return Color(white: 0.85) }
        if name.contains("gold") { return Color(red: 0.83, green: 0.69, blue: 0.22) }
        if name.contains("reserve") { return Color(red: 0.04, green: 0.15, blue: 0.4) }
        if name.contains("preferred") { return Color(red: 0.2, green: 0.45, blue: 0.75) }
        if name.contains("venture x") { return Color(red: 0.55, green: 0.1, blue: 0.1) }
        if name.contains("venture") { return Color(red: 0.75, green: 0.35, blue: 0.35) }
        
        return .orange
    }
    
    static func labelColor(for cardName: String) -> Color {
        if cardName.lowercased().contains("platinum") {
            return .black.opacity(0.6)
        }
        return .white
    }
}
