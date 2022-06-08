//
//  OnboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct OnboardView: View {
    @Binding var phoneNumber: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Sign up or log in with your phone #")
                    .font(.title).bold()
                TextField("(123) 456 7890", text: $phoneNumber)
                    .accentColor(.black)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
                Text("By pressing continue you agree to receive a text message from us")
             
                Button(action: {
                    print("DEBUG: Continue")
                }) {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white, lineWidth: 2)
                    )
                }
                .background(Color.black) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
            }
        }
        .padding(20)
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(phoneNumber: .constant(""))
    }
}
