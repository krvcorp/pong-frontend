import SwiftUI

struct WelcomeView: View {    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Connect with your college, completely anonymously.")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image("OnboardingInfo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth / 1.1)
                .padding(.bottom)
            
            
            Text("By clicking next and using Pong, you understand and agree to our [Terms of Service](https://pong.college/tos/) and [Privacy Policy](https://pong.college/privacy/).")
                .font(.footnote)
                .fontWeight(.medium)
                .accentColor(Color.pongAccent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
                

        }
        .padding(.horizontal, 15)
        .background(Color.pongSystemBackground)
        .padding(.vertical, 40)
    }
}
