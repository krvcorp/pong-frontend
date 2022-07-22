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
                    if phoneLoginVM.code.count == 6 {
                        Button(action: {
                            print("DEBUG: Continue to verify")
                            phoneLoginVM.otpVerify(loginVM: loginVM, verificationVM: verificationVM)
                        }) {
                            Text("Continue")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 18).bold())
                                .padding()
                                .foregroundColor(Color(UIColor.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                            )
                        }
                        .background(Color(UIColor.label)) // If you have this
                        .cornerRadius(20)         // You also need the cornerRadius here
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
            FloatShowingCodeWrong()
        }
        .popup(isPresented: $verificationVM.showingCodeExpired, type: .floater(), position: .top, animation: .spring(), autohideIn: 3) {
            FloatShowingCodeExpired()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Floats structs
struct FloatShowingCodeWrong: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                
                Text("Your code is wrong.")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        .padding(16)
        .background(Color(.red).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.4), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}

struct FloatShowingCodeExpired: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                
                Text("Your code has expired.")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        .padding(16)
        .background(Color(.red).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.4), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}
