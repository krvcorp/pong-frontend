import SwiftUI
import AlertToast
import Combine

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
                        .foregroundColor(Color.pongSystemWhite)
                        .font(.system(size: 30))
                    
                    if onboardingVM.referred || DAKeychain.shared["referred"] == "true" {
                        Text("Referred!")
                            .foregroundColor(Color.pongSystemWhite)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .accentColor(Color.pongSystemWhite)
                    } else {
                        TextField(text: $referralCode) {
                            Text("Enter code")
                                .foregroundColor(Color.pongSystemWhite)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .autocapitalization(.allCharacters)
                        .onReceive(Just(referralCode)) { _ in limitText() }
                        .disabled(onboardingVM.referred || DAKeychain.shared["referred"] == "true")
                        .accentColor(Color.pongSystemWhite)
                    }

                    Spacer()
                    
                    Button(action: {
                        if referralCode.count == 6 {
                            onboardingVM.setReferrer(referralCode: referralCode)
                        }
                    }) {
                        Text("enter")
                            .foregroundColor(Color.pongSystemWhite)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(referralCode.count != 6 || onboardingVM.referred || DAKeychain.shared["referred"] == "true")
                }
                .foregroundColor(Color.pongSystemWhite)
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
            AlertToast(type: .error(.red), title: "Sorry, this code is invalid.")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: LimitText
    func limitText() {
        let characterLimit = 6
        
        if referralCode.count > characterLimit {
            referralCode = String(referralCode.prefix(characterLimit))
        }
    }
}
