//
//  LegalSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/22/22.
//

import SwiftUI

struct LegalSheetView: View {
    var body: some View {
        ActionSheetView(bgColor: .white) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.system(size: 24))
                    
                    Text("Welcome to Sidechat. Please read this Terms of Use agreement (the “Terms of Use”) carefully. The Sidechat mobile application (“Mobile App”) and the services and resources available or enabled via the Mobile App (each a “Service” and collectively, the “Services”), are controlled by Flower Ave Inc. (“Sidechat”, “we”, or “us”). These Terms of Use, along with all supplemental terms that may be presented to you for your review and acceptance (collectively, the “Agreement”), govern your access to and use of the Services. By clicking on the “I Accept” button, completing the registration process, downloading or using the Mobile App, or otherwise accessing or using any of the Services, you represent that (1) you have read, understand, and agree to be bound by the Agreement, (2) you are of legal age to form a binding contract with Sidechat, and (3) you have the authority to enter into the Agreement. The term “you” refers to the individual identified during the registration process. If you do not agree to be bound by the Agreement, you may not access or use any of the Services.")
                        .font(.system(size: 14))
                        .opacity(0.6)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct LegalSheetView_Previews: PreviewProvider {
    static var previews: some View {
        LegalSheetView()
    }
}
