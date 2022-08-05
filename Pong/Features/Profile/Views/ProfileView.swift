//
//  ProfileView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import PopupView

struct ProfileView: View {
    // logic related to swipable TabView
    @Namespace var animation
    @State private var selectedFilter: ProfileFilterViewModel = .posts
    @StateObject private var profileVM = ProfileViewModel()
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            karmaInfo
                .background(Color(UIColor.tertiarySystemBackground))
                .padding(.horizontal, 30)
                .padding(.top, 20)

            profileFilterBar
                .background(Color(UIColor.tertiarySystemBackground))
                .padding(.top)
            
            profileFilteredItems
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .onAppear(perform: profileVM.getLoggedInUserInfo)
        .background(Color(UIColor.tertiarySystemBackground))
    }
    
    var profileFilterBar: some View {
        HStack {
            ForEach(ProfileFilterViewModel.allCases, id: \.rawValue) { item in
                LazyVStack {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == item ? .semibold : .regular)
                        .foregroundColor(selectedFilter == item ? Color(UIColor.label) : .gray)
                    
                    if selectedFilter == item {
                        Capsule()
                            .foregroundColor(Color(.systemBlue))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "filter", in: animation)
                        
                    } else {
                        Capsule()
                            .foregroundColor(Color(.clear))
                            .frame(height: 3)
                    }
                    
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.selectedFilter = item
                    }
                }
            }
        }
        .overlay(Divider().offset(x: 0, y: 16))
    }
    
    var karmaInfo: some View {
        ZStack {
            HStack {
                VStack(alignment: .center) {
                    Text(String(profileVM.totalKarma))
                    Text("Total Karma")
                        .font(.system(size: 10.0))
                }
                Spacer()
            }
            
            VStack(alignment: .center) {
                Text(String(profileVM.postKarma))
                Text("Post Karma")
                    .font(.system(size: 10.0))
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text(String(profileVM.commentKarma))
                    Text("Comment Karma")
                        .font(.system(size: 10.0))
                }
            }
        }
    }
    
    var profileFilteredItems: some View {
        TabView(selection: $selectedFilter) {
            ForEach(ProfileFilterViewModel.allCases, id: \.self) { view in
                RefreshableScrollView {
                    LazyVStack {
                        if view == .posts {
                            ForEach(profileVM.posts) { post in
                                NavigationLink(destination: PostView(post: post)) {
                                    PostBubble(post: post, postSettingsVM: postSettingsVM)
                                }
                            }
                        }
                        else if view == .saved {
                            ForEach(profileVM.savedPosts) { post in
                                PostBubble(post: post, postSettingsVM: PostSettingsViewModel())
                            }
                        }
                    }
                }
                .refreshable {
                    print("DEBUG: ProfileView pull to refresh")
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(settingsSheetVM: SettingsSheetViewModel(), postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
//    }
//}
