import SwiftUI
import AlertToast

struct ReferralOnboardingView: View {
    @EnvironmentObject var onboardingVM : OnboardingViewModel
    @State var referralCode: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("One last question. Were your referred by a friend?")
                    .font(.title).bold()
                
                // MARK: ReferralPageImage
                HStack {
                    Spacer()
                    Image("ReferralPageImage")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.screenWidth / 2)
                    Spacer()
                }
                
                Text("Enter their unique referral code below!")
                    .font(.title2)
                
                // MARK: Enter Referral Code
                if !onboardingVM.onBoarded {
                    HStack {
                        HStack {
                            TextField("Enter Code", text: $referralCode)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if referralCode == "" {
                                Button(action: {
                                    onboardingVM.setReferrer(referralCode: referralCode)
                                }) {
                                    Text("enter")
                                        .foregroundColor(Color(UIColor.quaternaryLabel))
                                        .font(.subheadline)
                                        .fontWeight(.heavy)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(true)
                            } else {
                                Button(action: {
                                    onboardingVM.setReferrer(referralCode: referralCode)
                                }) {
                                    Text("enter")
                                        .font(.subheadline)
                                        .fontWeight(.heavy)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(15)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
                // MARK: Already been referred
                else {
                    HStack {
                        HStack {
                            Text(referralCode == "" ? "you've been referred!" : referralCode)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                onboardingVM.setReferrer(referralCode: referralCode)
                            }) {
                                Text("enter")
                                    .foregroundColor(Color(UIColor.quaternaryLabel))
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(true)
                        }
                        .padding(15)
                    }
                    .background(Color(UIColor.systemGreen))
                    .cornerRadius(10)
                }
            }
            .padding(10)
        
            Spacer()
            
            Text("You can also find in the settings and info on how you can win free money!")
                .font(.subheadline)
        }
        .background(Color.pongSystemBackground)
        .padding(.bottom, 40)
        .toast(isPresenting: $onboardingVM.wrongCodeError) {
            AlertToast(type: .error(.red), title: "Wrong code!")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
