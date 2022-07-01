//
//  VerificationView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct VerificationView: View {
    @Binding var phoneNumber: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Enter the code we sent to")
                    .font(.title).bold()
                Text("(571) 552-5474")
                    .font(.title).bold()
                TextField("(123) 456 7890", text: $phoneNumber)
                    .accentColor(.gray)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
             
                Button(action: {
                    print("DEBUG: Continue")
                }) {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
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
        .padding(20)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(phoneNumber: .constant(""))
    }
}
