//
//  FeedView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import ScalingHeaderScrollView

struct FeedView: View {
    @Namespace var animation
    @State var selectedFilter: FeedFilterViewModel = .hot
    // observed objects
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var postSettingsVM: PostSettingsViewModel
    // variables
    @State private var isRefreshing = false
    @State private var offset = CGSize.zero
    // tracks scroll to top on recentposts on new post
    @State private var newPost = false
    var school: String // will need to filter entire page by community

// remove init function because unnecessary for now
//    init(_ school: String, _ selectedFilter: FeedFilterViewModel, _ feedVM: FeedViewModel, _ postSettingsVM: PostSettingsViewModel) {
//        self.school = school
//        self.selectedFilter = selectedFilter
//        self.feedVM = feedVM
//        self.postSettingsVM = postSettingsVM
//    }
    
    var body: some View {
        // ORIGINAL
        VStack(spacing: 0) {
            feedFilterBar
            feedItself
        }
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
        .background(Color(UIColor.tertiarySystemBackground))
        .overlay(Divider().offset(x: 0, y: 16))
    }
    
    var feedItself: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedFilter) {
                ForEach(FeedFilterViewModel.allCases, id: \.self) { view in
                    RefreshableScrollView {
                        ScrollViewReader { scrollReader in
                            // actual stack of post bubbles
                            LazyVStack {
                                // top
                                if view == .top {
                                    ForEach(feedVM.recentPosts, id: \.self) { post in
                                        NavigationLink(destination: PostView(post: Binding.constant(post))) {
                                            PostBubble(post: post, postSettingsVM: postSettingsVM, feedVM: feedVM)
                                        }
                                    }
                                }
                                // hot
                                else if view == .hot {
                                    ForEach(feedVM.recentPosts, id: \.self) { post in
                                        NavigationLink(destination: PostView(post: Binding.constant(post))) {
                                            PostBubble(post: post, postSettingsVM: postSettingsVM, feedVM: feedVM)
                                        }
                                    }
                                }
                                // recent
                                else if view == .recent {
                                    ForEach(feedVM.recentPosts, id: \.self) { post in
                                        NavigationLink(destination: PostView(post: Binding.constant(post))) {
                                            PostBubble(post: post, postSettingsVM: postSettingsVM, feedVM: feedVM)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 150)
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
                        feedVM.getPosts(selectedFilter: selectedFilter)
                    }
                    .onAppear {
                        if !feedVM.topPostsInitalOpen && selectedFilter == .top {
                            feedVM.getPosts(selectedFilter: .top)
                        } else if !feedVM.hotPostsInitalOpen && selectedFilter == .hot {
                            feedVM.getPosts(selectedFilter: .hot)
                        } else if !feedVM.recentPostsInitalOpen && selectedFilter == .recent {
                            feedVM.getPosts(selectedFilter: .recent)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all, edges: .bottom)
            
            // NewPost Overlay
            NavigationLink {
                NewPostView(newPost: $newPost)
            } label: {
                Image(systemName: "arrowshape.bounce.forward.fill")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 50, height: 50)
                    .padding()
            }
            .foregroundColor(Color(UIColor.tertiarySystemBackground))
            .background(Color(UIColor.label))
            .clipShape(Circle())
            .padding()
            .shadow(radius: 10)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(selectedFilter: .hot, feedVM: FeedViewModel(), postSettingsVM: PostSettingsViewModel(), school: "Harvard")
    }
}
