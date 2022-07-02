//
//  ContentView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginVM = LoginViewModel()
    @State private var showSettings = false
    
    var body: some View {
        if loginVM.isAuthenticated {
            MainInterfaceView
        } else {
            OnboardView(email: $loginVM.username, password: $loginVM.password)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    var MainInterfaceView: some View {
        ZStack(alignment: .topTrailing){
           
            MainTabView(showSettings: $showSettings)
            
            // tappable dark area
            if showSettings {
                ZStack {
                    Color(.black)
                        .opacity(showSettings ? 0.25 : 0.0)
                        
                }.onTapGesture {
                    withAnimation(.easeInOut) {
                        showSettings = false
                    }
                }
                .ignoresSafeArea()
            }
            
            // settings side menu
            SettingsView()
                .frame(minWidth: 200, maxWidth: 250)
                .offset(x: showSettings ? 0 : 300)
            
            // TODO user/group side menu
            
        }
    }
}


