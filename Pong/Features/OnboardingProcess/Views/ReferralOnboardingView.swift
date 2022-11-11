import SwiftUI
import AlertToast

struct ReferralOnboardingView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    @State var referralCode: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("One last question. Were your referred by a friend?")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("REFERRAL CODE")
                .font(.caption)
                .fontWeight(.heavy)
                .padding(.bottom, -20)
            
            // MARK: Enter Referral Code
            HStack {
                HStack {
                    Image("person")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30))
                    
                    TextField(text: $referralCode) {
                        Text("Enter code")
                            .foregroundColor(Color(hex:"FFFFFF"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    Spacer()
                    
                    Button(action: {
                        if referralCode != "" {
                            onboardingVM.setReferrer(referralCode: referralCode)
                        }
                    }) {
                        Text("enter")
                            .foregroundColor(referralCode != "" ? Color.white : Color(hex: "777777"))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(referralCode != "" ? false : true)
                }
                .padding(15)
            }
            .background(Color.pongAccent)
            .cornerRadius(50)
            
            Image("OnboardingReferral")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth / 1.1)
                .padding(.bottom)
        }
        .background(Color.pongSystemBackground)
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 60)
        .toast(isPresenting: $onboardingVM.wrongCodeError) {
            AlertToast(type: .error(.red), title: "Wrong code!")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
