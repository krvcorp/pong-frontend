//
//  OnboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct OnboardView: View {
    @Binding var email: String
    @Binding var password: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Sign up or log in with your email")
                    .font(.title).bold()
                TextField("example@example.com", text: $email)
                    .accentColor(.secondary)
                    .font(.title.bold())
                SecureField("admin", text: $password)
                    .accentColor(.secondary)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
                Text("By pressing continue you agree to receive a text message from us")
             
                Button(action: {
                    print("DEBUG: SIGN IN")
                    print("DEBUG: SIGN OUT")
                    loginVM.login()
                }) {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.primary, lineWidth: 2)
                    )
                }
                .background(Color(UIColor.label)) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
            }
        }
        .padding(20)
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(email: .constant(""), password: .constant(""))
    }
}
