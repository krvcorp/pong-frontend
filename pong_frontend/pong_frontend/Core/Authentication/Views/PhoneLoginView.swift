//
//  PhoneLoginView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/7/22.
//

import UIKit
import SwiftUI


struct PhoneLoginView: View {
    @Binding var phone: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Enter your phone number")
                    .font(.title).bold()
                TextField("1234567890", text: $phoneLoginVM.phone)
                    .keyboardType(.phonePad)
                    .accentColor(.secondary)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
                Text("By pressing continue you agree to receive a text message from us")
                
                NavigationLink(destination: VerificationView(code: $phoneLoginVM.code, phoneLoginVM: phoneLoginVM)) {
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
                .simultaneousGesture(TapGesture().onEnded{
                    print("VIEW Continue to verification")
                    phoneLoginVM.otpStart()
                })
                .background(Color(UIColor.label)) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
            }
        }
        .padding(20)
    }
}
