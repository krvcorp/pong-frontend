//
//  ContentView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @StateObject private var phoneLoginVM = PhoneLoginViewModel()
    @StateObject private var loginVM = LoginViewModel()
    // potentially add some ObservableObject that contains these two variables?
    @State private var showSettingsSheetView = false
    @State private var showLegalSheetView = false
    @StateObject private var postSettingsVM = PostSettingsViewModel()
    
    var body: some View {
        if DAKeychain.shared["token"] != nil && !loginVM.initialOnboard {
            MainInterfaceView
        } else if DAKeychain.shared["token"] != nil {
            WelcomeView(loginVM: loginVM)
        } else {
            OnboardView(phone: $phoneLoginVM.phone, loginVM: loginVM, phoneLoginVM: phoneLoginVM)
        }
    }
}

extension ContentView {
    var MainInterfaceView: some View {
        ZStack(alignment: .topTrailing){
            MainTabView(showSettingsSheetView: $showSettingsSheetView, showLegalSheetView: $showLegalSheetView, postSettingsVM: postSettingsVM)
                .popup(isPresented: $showSettingsSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                    SettingsSheetView(loginVM: loginVM, showSettings: $showSettingsSheetView, showLegalSheetView: $showLegalSheetView)
                }
                .popup(isPresented: $showLegalSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                    LegalSheetView()
                }
                .popup(isPresented: $postSettingsVM.showPostSettingsView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                    PostSettingsView()
                }

        }
    }
}


