import SwiftUI

struct ReferralOnboardingView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    @State var referralCode: String = ""
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                HStack () {
                    Button {
                        onboardingVM.onboard()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                    }
                }
                
                Text("One last question.")
                    .font(.title).bold()
                
                Text("Were you referred by a friend?")
                    .font(.title2).bold()
                
                Text("If so, enter their unique referral code below. If not, don't worry, just click the X in the top left and proceed to the app!")
                    .font(.title2)
                
                TextField("Enter Code", text: $referralCode)
                    .font(.title.bold())
            }
            .padding(10)
        
            Spacer()
        
            Button(action: {
                onboardingVM.setReferrer(referralCode: referralCode)
            }) {
                Text("Take me to Pong")
                    .frame(minWidth: 0, maxWidth: 150)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(UIColor.label), lineWidth: 2)
                )
            }
            .background(Color(UIColor.label))
            .cornerRadius(20)
        }
        .navigationBarHidden(true)
    }
}
