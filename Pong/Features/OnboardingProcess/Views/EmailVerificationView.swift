//
//  EmailVerificationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/8/22.
//

import SwiftUI

struct EmailVerificationView: View {
    private let logoDim: CGFloat = 128
    
    var body: some View {
        VStack {
            Image("pong_transparent_logo")
                .resizable()
                .frame(width: logoDim, height: logoDim)
                .shadow(color: Color(white: 0.05, opacity: 0.7), radius: 12, x: 0, y: 6)
                .padding(.top, 32)
            Text("Pong")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, -4)
            Text("Bounce your ideas")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(white: 0.7, opacity: 1))
            Spacer(minLength: 36)
            Text("Sign In with your College Email")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(white: 0.7, opacity: 1))
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                AuthManager.authManager.googleSignInButton()
            } label: {
                HStack {
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(8)
                    Text("Continue with Google")
                        .fontWeight(.semibold)
                        .foregroundColor(.poshDarkPurple)
                        .padding([.leading], -6)
                    Spacer()
                }
                .background(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding([.leading, .trailing], 44)
                .shadow(color: Color(white: 0.1, opacity: 0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            LinearGradient(stops: [
                .init(color: .richIndigoRedTint.indigoRedArray[1], location: 0),
                .init(color: .richIndigoRedTint.indigoRedArray[2], location: 0.2),
                .init(color: .richIndigoRedTint.indigoRedArray[6], location: 0.75),
                .init(color: .richIndigoRedTint.indigoRedArray[10], location: 1)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .statusBar(hidden: true)
    }
}



struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
    }
}
