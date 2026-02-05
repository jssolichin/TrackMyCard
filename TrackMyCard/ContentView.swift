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
                    Label("Cards", systemImage: "creditcard.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CardBenefit.self, UserCard.self], inMemory: true)
}
