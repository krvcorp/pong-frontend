//
//  ContentView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginVM = LoginViewModel()
    @StateObject private var postSettingsVM = PostSettingsViewModel()
    @ObservedObject var settingsSheetVM = SettingsSheetViewModel()
    
    var body: some View {
        if DAKeychain.shared["token"] != nil && !loginVM.initialOnboard {
            MainInterfaceView
        } else if DAKeychain.shared["token"] != nil {
            WelcomeView(loginVM: loginVM)
        } else {
            OnboardView(loginVM: loginVM)
        }
//        MainInterfaceView
    }
}

extension ContentView {
    var MainInterfaceView: some View {
        ZStack(alignment: .topTrailing){
            MainTabView(settingsSheetVM: settingsSheetVM, postSettingsVM: postSettingsVM)
        }
    }
}


