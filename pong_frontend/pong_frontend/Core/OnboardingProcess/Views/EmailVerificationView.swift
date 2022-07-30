//
//  EmailVerificationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/8/22.
//

import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    
    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                Text("Your phone number is ")
                    .font(.title).bold()
                
                Text(phoneLoginVM.phone)
                    .font(.title).bold()
                    .padding(.bottom)
                
                Text("Please sign in with your college email")
                    .font(.title).bold()
            }
            
            Spacer()
            
            Button {
                print("DEBUG: EmailVerificationView GoogleSignIn")
                loginVM.googleSignInButton(phoneLoginVM: phoneLoginVM)
            } label: {
                HStack {
                    Image("googlelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    Text("Sign in with Google")
                        .font(.title.bold())
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.white)
                .cornerRadius(8.0)
                .shadow(radius: 4.0)
            }
            
            Button {
                print("DEBUG: EmailVerificationView MicrosoftSignIn")
            } label: {
                HStack {
                    Image("microsoftlogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    Text("Sign in with Microsoft")
                        .font(.title.bold())
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.white)
                .cornerRadius(8.0)
                .shadow(radius: 4.0)
            }
        }
    }
}



struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(loginVM: LoginViewModel(), phoneLoginVM: PhoneLoginViewModel())
    }
}
