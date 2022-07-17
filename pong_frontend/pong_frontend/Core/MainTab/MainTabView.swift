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
    @State private var selection = 0
    @StateObject private var feedVM = FeedViewModel()
    
    var handler: Binding<Int> { Binding(
        get: { self.selection },
        set: {
            if $0 == self.selection {
                print("Refresh Home!")
                feedVM.getPosts(selectedFilter: .top)
                feedVM.getPosts(selectedFilter: .hot)
                feedVM.getPosts(selectedFilter: .recent)
            }
            self.selection = $0
        }
    )}
    
    var body: some View {
    
        TabView(selection: handler) {
            NavigationView {
                FeedView(school: "Harvard", selectedFilter: .hot, feedVM: feedVM)
            }
            .tabItem{Image(systemName: "house")}
            .tag(0)
            
            NavigationView {
                MessagesView()
            }
            .tabItem{Image(systemName: "envelope")}
            .tag(1)
            
            NavigationView {
                ProfileView(showSettings: $showSettings)
            }
            .tabItem{Image(systemName: "person")}
            .tag(2)
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

