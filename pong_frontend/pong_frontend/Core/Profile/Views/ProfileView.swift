//
//  ProfileView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedFilter: ProfileFilterViewModel = .posts
    @Namespace var animation
    @StateObject var api = API()
    
    var body: some View {
        
        VStack {
            ZStack {
                HStack {
                    VStack(alignment: .center) {
                        Text("201")
                        Text("Total Karma")
                            .font(.system(size: 10.0))
                    }
                    Spacer()
                }
                
                VStack(alignment: .center) {
                    Text("201")
                    Text("Post Karma")
                        .font(.system(size: 10.0))
                }
                
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("201")
                        Text("Comment Karma")
                            .font(.system(size: 10.0))
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            profileFilterBar
                .padding(.top)
            
            TabView(selection: $selectedFilter) {
                ForEach(ProfileFilterViewModel.allCases, id: \.self) { view in // This iterates through all of the enum cases.
                    // make something different happen in each case
                    ScrollView {
                        LazyVStack {
                            ForEach(api.posts) { post in
                                PostBubble(post: post, expanded: false)
                            }
                        }
                        .onAppear {
                            api.getPosts()
                        }
                    }.tag(view.rawValue) // by having the tag be the enum's raw value,
                                            // you can always compare enum to enum.
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all, edges: .bottom)
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
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
