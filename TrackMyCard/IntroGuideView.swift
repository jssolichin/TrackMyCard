import SwiftUI

struct IntroGuideView: View {
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "creditcard.and.123")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)
            
            VStack(spacing: 8) {
                Text("Track Your Benefits!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Easily track your benefits and perks.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 20) {
                InfoBullet(icon: "checkmark.seal", title: "Stay Informed", description: "We help you track your perks, but banks change their rules often.")
                InfoBullet(icon: "magnifyingglass", title: "Verify", description: "Always check your official bank app for the latest terms and eligibility.")
                InfoBullet(icon: "person.badge.shield.checkmark", title: "Independent Tool", description: "We are not affiliated with any bank. Names are property of their owners.")
                InfoBullet(icon: "exclamationmark.triangle", title: "Stay Safe", description: "You are responsible for meeting spending requirements and deadlines.")
            }
            .padding(.horizontal, 30)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("By continuing, you acknowledge that TrackMyCard is for informational purposes and is not liable for missed credits or financial losses.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: onComplete) {
                    Text("I Understand & Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 40)
        }
    }
}

struct InfoBullet: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    IntroGuideView(onComplete: {})
}
