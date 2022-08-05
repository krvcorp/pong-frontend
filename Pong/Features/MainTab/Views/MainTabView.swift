//
//  MainTabView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var mainTabVM = MainTabViewModel(initialIndex: 1, customItemIndex: 3)
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @State var school : String = "Boston University"

    var body: some View {
        TabView(selection: $mainTabVM.itemSelected) {
            FeedView(postSettingsVM: postSettingsVM)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
                .tag(1)
            
            LeaderboardView()
                .tabItem{
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
                .tag(2)

            NewPostView()
                .tabItem {
                    Image(systemName: "arrowshape.bounce.right.fill")
                }
                .tag(3)
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .tag(4)

            ProfileView(settingsSheetVM: settingsSheetVM, postSettingsVM: postSettingsVM)
                .tabItem{
                    Label("Profile", systemImage: "person")
                }
                .tag(5)
        }
        .alert(isPresented: $postSettingsVM.showDeleteConfirmationView) {
            Alert(
                title: Text("Delete post"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .default(
                    Text("Cancel")
                ),
                secondaryButton: .destructive(
                    Text("Delete"),
                    action: postSettingsVM.deletePost
                )
            )
        }
        .sheet(isPresented: $mainTabVM.isCustomItemSelected) {
            NewPostView()
        }
    }
}
