//
//  ProfileView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import PopupView

struct ProfileView: View {
    @State private var selectedFilter: ProfileFilterViewModel = .posts
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if profileVM.selectedProfileFilter == .posts {
                    ForEach($profileVM.posts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                else if profileVM.selectedProfileFilter == .saved {
                    ForEach($profileVM.savedPosts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .onAppear {
                UITableView.appearance().showsVerticalScrollIndicator = false
                profileVM.getLoggedInUserInfo()
            }
            .navigationTitle("Your Profile")
            .toolbar {
                ToolbarItem (placement: .principal) {
                    HStack {
                        Picker("Profile Filter", selection: $profileVM.selectedProfileFilter) {
                            Text("Posts").tag(ProfileFilter.posts)
                            Text("Saved").tag(ProfileFilter.saved)
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                        .onChange(of: profileVM.selectedProfileFilter) { newValue in
                            print("DEBUG: profileVM changed filter!")
                        }
                    }
                    .padding()
                }
                ToolbarItem {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .accentColor(Color(UIColor.label))
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

