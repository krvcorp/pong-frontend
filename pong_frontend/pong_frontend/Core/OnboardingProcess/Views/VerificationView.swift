//
//  VerificationView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import iPhoneNumberField

struct ToastsState {
    var showingCodeWrong = false
    var showingCodeExpired = false
}

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var bannerVM = BannerViewModel()
    @State var floats = ToastsState()
    
    var body: some View {

        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Enter the code we sent to")
                        .font(.title).bold()
                    Text("\(phoneLoginVM.phone)")
                        .font(.title).bold()
                    TextField("ABC123", text: $phoneLoginVM.code)
                        .textInputAutocapitalization(.never)
                        .accentColor(.gray)
                        .font(.title.bold())
                }
                
                Spacer()
                
                VStack {
                    if phoneLoginVM.code.count == 6 {
                        Button(action: {
                            print("DEBUG: Continue to verify")
                            phoneLoginVM.otpVerify(loginVM: loginVM, bannerVM: bannerVM)
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
        .banner(data: $bannerVM.bannerData, show: $bannerVM.showBanner)
        .navigationBarTitleDisplayMode(.inline)
    }
}
