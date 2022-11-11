import SwiftUI

struct RulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Be yourself with just a few [rules](https://www.pong.college/rules/). Basically, don't be an asshole.")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Image("OnboardingRules")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth / 1.1)
                .padding(.bottom)
            
        }
        .background(Color.pongSystemBackground)
        .padding(.horizontal, 15)
        .padding(.top, 40)
        .padding(.bottom, 60)
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
    }
}
