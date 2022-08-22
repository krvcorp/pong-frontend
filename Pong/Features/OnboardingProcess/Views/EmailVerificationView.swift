//
//  EmailVerificationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/8/22.
//

import SwiftUI

struct EmailVerificationView: View {
    
    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                Text("Please sign in with your college email")
                    .font(.title).bold()
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                print("DEBUG: EmailVerificationView GoogleSignIn")
                AuthManager.authManager.googleSignInButton()
            } label: {
                HStack {
                    Image("GoogleLogo")
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
        }
    }
}



struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
    }
}
