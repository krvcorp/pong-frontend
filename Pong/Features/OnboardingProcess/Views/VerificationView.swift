//
//  VerificationView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import iPhoneNumberField
import PopupView

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var verificationVM = VerificationViewModel()
    
    var body: some View {

        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Enter the code we sent to")
                        .font(.title).bold()
                    Text("\(phoneLoginVM.phone)")
                        .font(.title).bold()
                    TextField("ABC123", text: $phoneLoginVM.code)
                        .textInputAutocapitalization(.characters)
                        .accentColor(.gray)
                        .font(.title.bold())
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("Didn't get code?")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            print("DEBUG: VerificationView Resend OTP")
                            phoneLoginVM.otpStart()
                        }) {
                            Text("Resend OTP")
                                .font(.subheadline.bold())
                        }
                    }

                    if phoneLoginVM.code.count == 6 {
                        Button(action: {
                            print("DEBUG: VerificationView Continue to verify")
                            phoneLoginVM.otpVerify(loginVM: loginVM, verificationVM: verificationVM)
                        }) {
                            Text("Continue")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 18).bold())
                                .padding()
                                .foregroundColor(Color(UIColor.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(UIColor.systemBackground), lineWidth: 2))
                                .background(Color(UIColor.label)) // If you have this
                                .cornerRadius(20)         // You also need the cornerRadius here
                        }
                    } else {
                        Text("Continue")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .font(.system(size: 18).bold())
                            .padding()
                            .foregroundColor(Color(UIColor.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(UIColor.systemBackground), lineWidth: 2))
                            .background(Color(UIColor.systemFill)) // If you have this
                            .cornerRadius(20)         // You also need the cornerRadius here
                    }

                }
            }
            .padding(20)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .popup(isPresented: $verificationVM.showingCodeWrong, type: .floater(), position: .top, animation: .spring(), autohideIn: 3) {
            FloatWarning(message: "Your code is wrong.")
        }
        .popup(isPresented: $verificationVM.showingCodeExpired, type: .floater(), position: .top, animation: .spring(), autohideIn: 3) {
            FloatWarning(message: "Your code has expired!")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(phoneLoginVM: PhoneLoginViewModel(), loginVM: LoginViewModel())
    }
}
