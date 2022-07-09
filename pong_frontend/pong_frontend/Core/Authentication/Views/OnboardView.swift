//
//  OnboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import UIKit
import SwiftUI


struct OnboardView: View {
    @Binding var phone: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    
    
    var body: some View {
        if phoneLoginVM.phoneIsVerified {
            GoogleSignInView(loginVM: loginVM, phoneLoginVM: phoneLoginVM)
        } else {
            NavigationView {
                PhoneLoginView(phone: $phoneLoginVM.phone, loginVM: loginVM, phoneLoginVM: phoneLoginVM)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
//        VerificationView(phoneNumber: $phoneLoginVM.phone)
//        PhoneLoginView(phone: $phoneLoginVM.phone, loginVM: loginVM, phoneLoginVM: phoneLoginVM)

    }
}



struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(phone: .constant(""), loginVM: LoginViewModel(), phoneLoginVM: PhoneLoginViewModel())
    }
}
