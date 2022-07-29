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
    @StateObject private var settingsSheetVM = SettingsSheetViewModel()
    @StateObject private var postSettingsVM = PostSettingsViewModel()
    @StateObject private var feedVM = FeedViewModel()
    
    
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
            MainTabView(settingsSheetVM: settingsSheetVM, postSettingsVM: postSettingsVM, feedVM: feedVM)
            // SettingsSheetView
            .popup(isPresented: $settingsSheetVM.showSettingsSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                SettingsSheetView(loginVM: loginVM, settingsSheetVM: settingsSheetVM)
            }
            // AccountSheetView
            .popup(isPresented: $settingsSheetVM.showAccountSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                AccountsSheetView(settingsSheetVM: settingsSheetVM)
            }
            // PreferencesSheetsView
            .popup(isPresented: $settingsSheetVM.showPreferencesSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                PreferencesSheetView(settingsSheetVM: settingsSheetVM)
            }
            // NotificationsSheetsView
            .popup(isPresented: $settingsSheetVM.showNotificationsSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                NotificationsSheetView(settingsSheetVM: settingsSheetVM)
            }
            // LegalSheetView
            .popup(isPresented: $settingsSheetVM.showLegalSheetView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                LegalSheetView(settingsSheetVM: settingsSheetVM)
            }
            // PostSettingsView
            .popup(isPresented: $postSettingsVM.showPostSettingsView, type: .toast, position: .bottom, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                PostSettingsView(postSettingsVM: postSettingsVM)
            }
            // DeleteConfirmationView
            .popup(isPresented: $postSettingsVM.showDeleteConfirmationView, type: .`default`, closeOnTap: false, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                DeleteConfirmationView(postSettingsVM: postSettingsVM, feedVM: feedVM)
            }
        }
    }
}


