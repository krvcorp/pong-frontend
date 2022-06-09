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
            
            ScrollView {
                LazyVStack {
                    ForEach(0 ... 20, id: \.self) { _ in
//                        PostBubble(post: Post(id: "12345",
//                                              user: "rdaga",
//                                              title: "This is a funny post by someone funny",
//                                              createdAt: Date(),
//                                              updatedAt: Date(),
//                                              expanded: false))
                    }
                }
            }
        }
    }
    
    var profileFilterBar: some View {
        HStack {
            ForEach(ProfileFilterViewModel.allCases, id: \.rawValue) { item in
                LazyVStack {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == item ? .semibold : .regular)
                        .foregroundColor(selectedFilter == item ? .black : .gray)
                    
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
