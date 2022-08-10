////
////  PhoneLoginView.swift
////  Pong
////
////  Created by Khoi Nguyen on 7/7/22.
////
//
//import SwiftUI
//import iPhoneNumberField
//
//
//struct PhoneLoginView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var loginVM : LoginViewModel
//    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
//    
//    var body: some View {
//        VStack {
//            VStack(alignment: .leading) {
//                Text("Enter your phone number")
//                    .font(.title).bold()
//                iPhoneNumberField("(000) 000-0000", text: $phoneLoginVM.phone)
//                    .font(UIFont(size: 30, weight: .bold))
//                    .maximumDigits(10)
//                    .clearButtonMode(.whileEditing)
//                    .accentColor(Color(UIColor.label))
//            }
//            
//            Spacer()
//            
//            VStack {
//                Text("By pressing continue you agree to receive a text message from us")
//                // phoneLoginVM.phone.count == 14 means phone field needs to be completely filled with a length of 14 to click continue
//                if phoneLoginVM.phone.count == 14 {
//                    NavigationLink(destination: VerificationView(phoneLoginVM: phoneLoginVM, loginVM: loginVM)) {
//                        Text("Continue")
//                            .frame(minWidth: 0, maxWidth: .infinity)
//                            .font(.system(size: 18).bold())
//                            .padding()
//                            .foregroundColor(Color(UIColor.systemBackground))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 5)
//                                    .stroke(Color(UIColor.systemBackground), lineWidth: 2)
//                            )
//                    }
//                    .simultaneousGesture(TapGesture().onEnded{
//                        print("VIEW Continue to verification")
//                        phoneLoginVM.otpStart()
//                        loginVM.initialOnboard = true
//                    })
//                    .background(Color(UIColor.label)) // If you have this
//                    .cornerRadius(20)         // You also need the cornerRadius here
//                } else {
//                    Text("Continue")
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .font(.system(size: 18).bold())
//                        .padding()
//                        .foregroundColor(Color(UIColor.systemBackground))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 5)
//                                .stroke(Color(UIColor.systemBackground), lineWidth: 2)
//                        )
//                        .background(Color(UIColor.systemFill)) // If you have this
//                        .cornerRadius(20)         // You also need the cornerRadius here
//                }
//
//            }
//        }
//        .padding(20)
//    }
//}
