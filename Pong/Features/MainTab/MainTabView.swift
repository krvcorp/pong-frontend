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
    
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @State var school : String = "Boston University"
    
    var body: some View {
        TabView {
            FeedView(school: $school, selectedFilter: .hot, postSettingsVM: postSettingsVM)
                .tabItem{
                    Label("Home", systemImage: "house")
                }

            MessagesView()
            .tabItem{
                Label("Messages", systemImage: "message")
            }

            ProfileView(settingsSheetVM: settingsSheetVM, postSettingsVM: postSettingsVM)
            .tabItem{
                Label("Profile", systemImage: "person")
            }
            
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        // this bad boy is the toolbar
    }
}
