//
//  OnboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct OnboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var loginVM : LoginViewModel
    @StateObject private var phoneLoginVM = PhoneLoginViewModel()
    
    var body: some View {
        if phoneLoginVM.phoneIsVerified {
            EmailVerificationView(loginVM: loginVM, phoneLoginVM: phoneLoginVM)
        } else {
            NavigationView {
                PhoneLoginView(loginVM: loginVM, phoneLoginVM: phoneLoginVM)
                    .navigationBarHidden(true)
            }
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(loginVM: LoginViewModel())
    }
}