//
//  WelcomeView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Sidechat")
                    .font(.title).bold()
                
                
                Text("This is a place to connect with your college community anonymously")
                    .font(.title2).bold()
                
                Text("Anonymity can help us express ourselves in positive ways through jokes, confessions, or memes.")
                
                Text("This is not a place to bully people, spread rumors, or post spam or obscene content.")
             

            }
            .padding(10)
        
            Button(action: {
                print("DEBUG: Continue")
            }) {
                Text("Continue")
                    .frame(minWidth: 0, maxWidth: 150)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.primary, lineWidth: 2)
                )
            }
            .background(Color.secondary) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here
            
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
