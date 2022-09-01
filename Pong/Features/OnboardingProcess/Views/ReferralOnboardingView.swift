import SwiftUI

struct ReferralOnboardingView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    @State var referralCode: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("One last question.")
                    .font(.title).bold()
                
                Text("Were you referred by a friend?")
                    .font(.title2).bold()
                
                Text("If so, enter their unique referral code below!")
                    .font(.title2)
                
                if !onboardingVM.onBoarded {
                    HStack {
                        TextField("Enter Code", text: $referralCode)
                            .font(.title.bold())
                        
                        Button(action: {
                            onboardingVM.setReferrer(referralCode: referralCode)
                        }) {
                            Image(systemName: "person.fill.checkmark")
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
                } else {
                    HStack {
                        Text(referralCode)
                            .font(.title.bold())
                        
                        Spacer()
                        
                        Button(action: {
                            onboardingVM.setReferrer(referralCode: referralCode)
                        }) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.system(size: 18).bold())
                                .padding()
                                .foregroundColor(Color(UIColor.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(UIColor.systemGreen), lineWidth: 2)
                            )
                        }
                        .disabled(true)
                        .background(Color(UIColor.systemGreen))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(10)
        
            Spacer()
        }
        .padding(.bottom, 40)
    }
}
