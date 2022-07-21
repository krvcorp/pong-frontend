//
//  ProfileView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedFilter: ProfileFilterViewModel = .posts
    @StateObject private var profileVM = ProfileViewModel()
    @Namespace var animation
    @StateObject var api = API()
    @Binding var showSettings: Bool
    
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
        .background(Color(UIColor.tertiarySystemBackground))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Me")
                    .font(.title.bold())
            }
            
            ToolbarItem(){
                Button {
                    withAnimation(.easeInOut) {
                        showSettings.toggle()
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            profileVM.getLoggedInUserInfo()
        }
        
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
            ForEach(ProfileFilterViewModel.allCases, id: \.self) { view in // This iterates through all of the enum cases.
                // make something different happen in each case
                RefreshableScrollView {
                    LazyVStack {
                        ForEach(api.posts) { post in
                            PostBubble(post: post)
                        }
                    }
                    .onAppear {
                        api.getPosts()
                    }
                }
                .refreshable {
                    do {
                      // Sleep for 2 seconds
                      try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                    } catch {}
                }
                .tag(view.rawValue) // by having the tag be the enum's raw value,
                                        // you can always compare enum to enum.
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

