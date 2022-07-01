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
    @Binding var showSettings: Bool
    
    var body: some View {
    
        TabView {
            NavigationView {
                FeedView(school: "Harvard")
            }.tabItem{Image(systemName: "house")}
            
            NavigationView {
                MessagesView()
            }.tabItem{Image(systemName: "envelope")}
            
            NavigationView {
                ProfileView(showSettings: $showSettings)
            }.tabItem{Image(systemName: "person")}
        }
        .onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            tabBarAppearance.backgroundColor = .secondarySystemBackground
            
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            navigationBarAppearance.backgroundColor = .secondarySystemBackground
        }
    }
}

