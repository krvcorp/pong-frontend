//
//  FeedView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct FeedView: View {
    var school: String // will need to filter entire page by community
    @Namespace var animation
    @State var selectedFilter: FeedFilterViewModel
    @ObservedObject var feedVM: FeedViewModel
    @State private var isRefreshing = false
    @State private var offset = CGSize.zero
    @State private var newPost = false

    init(_ school: String, _ selectedFilter: FeedFilterViewModel, _ feedVM: FeedViewModel) {
        self.school = school
        self.selectedFilter = selectedFilter
        self.feedVM = feedVM
    }
    
    var body: some View {
        VStack(spacing: 0) {
            feedFilterBar
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
                        .font(.subheadline.bold())
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
        .background(Color(UIColor.secondarySystemBackground))
        .overlay(Divider().offset(x: 0, y: 16))
    }
    
    var feedItself: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedFilter) {
                ForEach(FeedFilterViewModel.allCases, id: \.self) { view in
                    RefreshableScrollView {
                        ScrollViewReader { scrollReader in
                            
                            // actual stack of post bubbles
                            LazyVStack {
                                // top
                                if view == .top {
                                    ForEach(feedVM.topPosts) { post in
                                        PostBubble(post: post)
                                    }
                                }
                                
                                
                                // hot
                                else if view == .hot {
                                    ForEach(feedVM.hotPosts) { post in
                                        PostBubble(post: post)
                                    }
                                }
                                
                                // recent
                                else if view == .recent {
                                    ForEach(feedVM.recentPosts) { post in
                                        PostBubble(post: post)
                                    }
                                }
                                
                                // default
                                else {
                                    ForEach(feedVM.hotPosts) { post in
                                        PostBubble(post: post)
                                    }
                                }
                            }
                            .onChange(of: newPost, perform: { value in
                                if value {
                                    print("DEBUG: Switch and Scroll to Top")
                                    selectedFilter = .recent
                                    scrollReader.scrollTo("top") // scrolls to component with id "top" which is a spacer piece in PullToRefresh view
                                    newPost = false
                                    feedVM.getPosts(selectedFilter: selectedFilter)
                                }
                            })
                        }
                    }
                    .refreshable {
                        do {
                          // Sleep for 2 seconds
                          try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                        } catch {}
                        feedVM.getPosts(selectedFilter: selectedFilter)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all, edges: .bottom)
            
            NavigationLink {
                NewPostView(newPost: $newPost)
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
        // when home appears, call api and load
        .onAppear {
            if !feedVM.initalOpen {
                feedVM.getPosts(selectedFilter: .hot)
                feedVM.getPosts(selectedFilter: .recent)
                feedVM.getPosts(selectedFilter: .top)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView("Harvard", .hot, FeedViewModel())
    }
}
