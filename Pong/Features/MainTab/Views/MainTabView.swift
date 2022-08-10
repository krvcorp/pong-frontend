//
//  MainTabView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var mainTabVM = MainTabViewModel(initialIndex: 1, customItemIndex: 3)
    @StateObject private var postSettingsVM = PostSettingsViewModel()

    var body: some View {
        TabView(selection: $mainTabVM.itemSelected) {
            // MARK: FeedView
            FeedView(postSettingsVM: postSettingsVM)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
                .tag(1)
            
            // MARK: Stats and Leaderboard
            LeaderboardView()
                .tabItem{
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
                .tag(2)

            // MARK: NewPostView
            NewPostView()
                .tabItem {
                    Image(systemName: "arrowshape.bounce.right.fill")
                }
                .tag(3)
            
            // MARK: NotificationsView
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .tag(4)

            // MARK: ProfileView
            ProfileView(postSettingsVM: postSettingsVM)
                .tabItem{
                    Label("Profile", systemImage: "person")
                }
                .tag(5)
        }
//        .alert(isPresented: $postSettingsVM.showDeleteConfirmationView) {
//            Alert(
//                title: Text("Delete post"),
//                message: Text("Are you sure you want to delete \(postSettingsVM.post.title)"),
//                primaryButton: .default(
//                    Text("Cancel")
//                ),
//                secondaryButton: .destructive(
//                    Text("Delete"),
//                    action: postSettingsVM.deletePost
//                )
//            )
//        }
        .sheet(isPresented: $mainTabVM.isCustomItemSelected) {
            NewPostView()
        }
    }
}
