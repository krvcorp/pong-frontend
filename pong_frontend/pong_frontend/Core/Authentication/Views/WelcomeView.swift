//
//  WelcomeView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var loginVM : LoginViewModel
    
    var body: some View {
        
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                Text("Pong")
                    .font(.title).bold()
                
                
                Text("This is a place to connect with your college community anonymously")
                    .font(.title2).bold()
                
                Text("Anonymity can help us express ourselves in honest ways. Controversial opinions, memes, confessions, we really don't care as anything is fair game.")
                
                Text("Just kidding. We will flag content that we believe would violate your school's handbook. Identification of any form is not allowed unless we believe you're a significant public figure. By agreeing, you understand this and Terms of Services in your settings.")

            }
            .padding(10)
        
            Spacer()
            
            Button(action: {
                print("DEBUG: Agree")
                let _ = UserDefaults.standard.removeObject(forKey: "hasAgreed")
                let _ = UserDefaults.standard.setValue(false, forKey: "initialOnboard")
                loginVM.initialOnboard = false
            }) {
                Text("Agree")
                    .frame(minWidth: 0, maxWidth: 150)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(UIColor.label), lineWidth: 2)
                )
            }
            .background(Color(UIColor.label)) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here
            
        }
        .navigationBarHidden(true)
    }
}
