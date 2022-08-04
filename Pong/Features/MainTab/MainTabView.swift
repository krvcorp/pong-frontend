//
//  MainTabView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

enum Tabs: String {
    case feed
    case messages
    case profile
}

struct MainTabView: View {
    
    var body: some View {
        TabView {
//            FeedView()
//            .tabItem{Image(systemName: "house")}

            MessagesView()
            .tabItem{
                Label("Messages", systemImage: "message")
            }

//            ProfileView()
//            .tabItem{
//                Label("Profile", systemImage: "person")
//            }
            
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        // this bad boy is the toolbar
    }
}
