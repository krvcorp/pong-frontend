//
//  ContentView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ContentView: View {
    @State private var loggedIn = true
    @State private var showSettings = false

    var body: some View {
        if loggedIn {
            MainInterfaceView
        } else {
            OnboardView(phoneNumber: .constant(""))
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
            
            SettingsView()
                .frame(minWidth: 200, maxWidth: 250)
                .offset(x: showSettings ? 0 : 300)
        }
    }
}
