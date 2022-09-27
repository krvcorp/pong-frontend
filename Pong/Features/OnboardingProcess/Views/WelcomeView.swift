import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                Text("Connect with your college community, anonymously.")
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Image("OnboardSchoolImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth / 1.1)
                
                Spacer()
                
                Text("By using Pong, you understand our [Terms of Service](https://www.pong.blog/legal) and [Privacy Policy](https://www.pong.blog/legal)")

            }
            .padding(15)
        }
        .padding()
        .padding(.bottom, 20)
    }
}
