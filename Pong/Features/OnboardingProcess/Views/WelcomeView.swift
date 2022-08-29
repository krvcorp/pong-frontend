import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Pong")
                    .font(.title).bold()
                
                Text("This is a place to connect with your college community, anonymously.")
                    .font(.title2).bold()
                
                Text("Anonymity can help us express ourselves in honest ways. Controversial opinions, memes, confessions. We really don't care as anything is fair game.")
                
                Text("Just one rule: identification of others in any form isn't allowed. After all, you'd want to remain anonymous too, wouldn't you?")

            }
            .padding(10)
        
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onboardingVM.welcomed = true
            } label: {
                Label("Agree", systemImage: "checkmark.seal")
            }
            .cornerRadius(20)
        }
    }
}
