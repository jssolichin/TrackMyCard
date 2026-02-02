import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("My Benefits", systemImage: "list.bullet.rectangle.portrait")
                }
            
            AddCardView()
                .tabItem {
                    Label("Add Card", systemImage: "creditcard.circle")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CardBenefit.self, UserCard.self], inMemory: true)
}
