//
//  FeedView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct FeedView: View {
    var school: String
    @State var selectedFilter: FeedFilterViewModel
    @StateObject var api = API()
    @Namespace var animation

    var body: some View {
        VStack {
            feedFilterBar
                .padding(.top)
            
            feedItself
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    ChooseLocationView()
                } label: {
                    Text("Harvard")
                        .font(.title.bold())
                        .foregroundColor(Color(UIColor.label))
                }
            }
            
            ToolbarItem(){
                NavigationLink {
                    LeaderboardView()
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var feedFilterBar: some View {
        HStack {
            ForEach(FeedFilterViewModel.allCases, id: \.rawValue) { item in
                VStack {
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
    
    var feedItself: some View {
        ZStack(alignment: .bottom) {
            // Posts information goes here
            TabView(selection: $selectedFilter) {
                ForEach(FeedFilterViewModel.allCases, id: \.self) { view in // This iterates through all of the enum cases.
                    // make something different happen in each case
                    ScrollView {
                        LazyVStack {
                            ForEach(api.posts) { post in
                                PostBubble(post: post, expanded: false)
                            }
                        }
                        .onAppear {
                            print("DEBUG: GETPOSTS")
                            api.getPosts()
                        }
                    }.tag(view.rawValue) // by having the tag be the enum's raw value,
                                            // you can always compare enum to enum.
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all, edges: .bottom)
            
            NavigationLink {
                NewPostView()
            } label: {
                Text("New Post")
                    .frame(minWidth: 100, maxWidth: 150)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(UIColor.systemBackground), lineWidth: 2))
            }
            .background(Color(UIColor.label)) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here
            .padding(.bottom)
        }
    }
}


