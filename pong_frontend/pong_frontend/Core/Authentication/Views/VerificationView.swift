//
//  VerificationView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var code: String
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Enter the code we sent to")
                    .font(.title).bold()
                Text("\(phoneLoginVM.phone)")
                    .font(.title).bold()
                TextField("ABC123", text: $phoneLoginVM.code)
                    .textCase(.uppercase) // not working?
                    .textInputAutocapitalization(.characters) // not working?
                    .accentColor(.gray)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
             
                Button(action: {
                    print("DEBUG: Continue to verify")
                    phoneLoginVM.otpVerify()
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
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(code: .constant(""), phoneLoginVM: PhoneLoginViewModel())
    }
}
