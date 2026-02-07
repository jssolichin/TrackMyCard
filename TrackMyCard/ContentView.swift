import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @State private var showingIntro = false

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
        .onAppear {
            if !hasSeenDisclaimer {
                showingIntro = true
            }
        }
        .fullScreenCover(isPresented: $showingIntro) {
            IntroGuideView {
                hasSeenDisclaimer = true
                showingIntro = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CardBenefit.self, UserCard.self], inMemory: true)
}
