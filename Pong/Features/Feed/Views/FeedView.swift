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
    // observed objects
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var postSettingsVM: PostSettingsViewModel

    init(school: Binding<String>, postSettingsVM: PostSettingsViewModel) {
        self.feedVM = FeedViewModel(school: school)
        self.postSettingsVM = postSettingsVM
    }
    
    var body: some View {
        
        // ORIGINAL
        NavigationView {
            TabView(selection: $feedVM.selectedFeedFilter) {
                ForEach(FeedFilter.allCases, id: \.self) { view in
                    ScrollView {
                        if feedVM.selectedFeedFilter == .top {
                            ForEach(feedVM.topPosts, id: \.self) { post in
                                NavigationLink(destination: PostView(post: post)) {
                                    PostBubble(post: post, postSettingsVM: postSettingsVM)
                                }
                            }
                        }
                        // hot
                        else if feedVM.selectedFeedFilter == .hot {
                            ForEach(feedVM.hotPosts, id: \.self) { post in
                                NavigationLink(destination: PostView(post: post)) {
                                    PostBubble(post: post, postSettingsVM: postSettingsVM)
                                }
                            }
                        }
                        // recent
                        else if feedVM.selectedFeedFilter == .recent {
                            ForEach(feedVM.recentPosts, id: \.self) { post in
                                NavigationLink(destination: PostView(post: post)) {
                                    PostBubble(post: post, postSettingsVM: postSettingsVM)
                                }
                            }
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                if feedVM.topPostsInitalOpen && feedVM.selectedFeedFilter == .top {
                    feedVM.getPosts(selectedFeedFilter: .top)
                } else if feedVM.hotPostsInitalOpen && feedVM.selectedFeedFilter == .hot {
                    feedVM.getPosts(selectedFeedFilter: .hot)
                } else if feedVM.recentPostsInitalOpen && feedVM.selectedFeedFilter == .recent {
                    feedVM.getPosts(selectedFeedFilter: .recent)
                }
//                if feedVM.selectedFeedFilter == .top {
//                    feedVM.getPosts(selectedFeedFilter: .top)
//                } else if feedVM.selectedFeedFilter == .hot {
//                    feedVM.getPosts(selectedFeedFilter: .hot)
//                } else if feedVM.selectedFeedFilter == .recent {
//                    feedVM.getPosts(selectedFeedFilter: .recent)
//                }
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    Picker("Feed Filter", selection: $feedVM.selectedFeedFilter) {
                        Text("Top").tag(FeedFilter.top)
                        Text("Hot").tag(FeedFilter.hot)
                        Text("Recent").tag(FeedFilter.recent)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .onChange(of: feedVM.selectedFeedFilter) { newValue in
                        print("DEBUG: feedVM changed filter!")
                        feedVM.getPosts(selectedFeedFilter: newValue)
                    }
                }
                .background(Color(UIColor.systemBackground))
                .padding()
            }
            .navigationTitle("Boston University")
            .toolbar {
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "message")
                }
            }
        }
        .accentColor(Color(UIColor.label))
        .sheet(isPresented: $feedVM.isShowingNewPostSheet) {
            NewPostView()
        }
        .sheet(isPresented: $postSettingsVM.showDeleteConfirmationView) {
            DeleteConfirmationView(postSettingsVM: postSettingsVM)
        }
    }
    // old content
//    var feedFilterBar: some View {
//        HStack {
//            ForEach(FeedFilterViewModel.allCases, id: \.rawValue) { item in
//                VStack {
//                    Text(item.title)
//                        .font(.subheadline.bold())
//                        .foregroundColor(selectedFilter == item ? Color(UIColor.label) : .gray)
//                    if selectedFilter == item {
//                        Capsule()
//                            .foregroundColor(Color(.systemBlue))
//                            .frame(height: 3)
//                            .matchedGeometryEffect(id: "filter", in: animation)
//                    } else {
//                        Capsule()
//                            .foregroundColor(Color(.clear))
//                            .frame(height: 3)
//                    }
//                }
//                .onTapGesture {
//                    withAnimation(.easeInOut) {
//                        self.selectedFilter = item
//                    }
//                }
//            }
//        }
//        .background(Color(UIColor.tertiarySystemBackground))
//        .overlay(Divider().offset(x: 0, y: 16))
//    }
//
//    var feedItself: some View {
//        ZStack(alignment: .bottomTrailing) {
//            TabView(selection: $selectedFilter) {
//                ForEach(FeedFilterViewModel.allCases, id: \.self) { view in
//                    RefreshableScrollView {
//                        ScrollViewReader { scrollReader in
//                            // actual stack of post bubbles
//                            LazyVStack {
//                                // top
//                                if view == .top {
//                                    ForEach(feedVM.topPosts, id: \.self) { post in
//                                        NavigationLink(destination: PostView(post: post)) {
//                                            PostBubble(post: post, postSettingsVM: postSettingsVM)
//                                        }
//                                    }
//                                }
//                                // hot
//                                else if view == .hot {
//                                    ForEach(feedVM.hotPosts, id: \.self) { post in
//                                        NavigationLink(destination: PostView(post: post)) {
//                                            PostBubble(post: post, postSettingsVM: postSettingsVM)
//                                        }
//                                    }
//                                }
//                                // recent
//                                else if view == .recent {
//                                    ForEach(feedVM.recentPosts, id: \.self) { post in
//                                        NavigationLink(destination: PostView(post: post)) {
//                                            PostBubble(post: post, postSettingsVM: postSettingsVM)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.bottom, 150)
//                            .onChange(of: feedVM.newPost, perform: { value in
//                                if value {
//                                    print("DEBUG: Switch and Scroll to Top")
//                                    selectedFilter = .recent
//                                    scrollReader.scrollTo("top") // scrolls to component with id "top" which is a spacer piece in PullToRefresh view
//                                    feedVM.newPost = false
//                                    feedVM.getPosts(selectedFilter: selectedFilter)
//                                }
//                            })
//                        }
//                    }
//                    .refreshable {
//                        feedVM.getPosts(selectedFilter: selectedFilter)
//                    }
//                    .onAppear {
////                        if !feedVM.topPostsInitalOpen && selectedFilter == .top {
////                            feedVM.getPosts(selectedFilter: .top)
////                        } else if !feedVM.hotPostsInitalOpen && selectedFilter == .hot {
////                            feedVM.getPosts(selectedFilter: .hot)
////                        } else if !feedVM.recentPostsInitalOpen && selectedFilter == .recent {
////                            feedVM.getPosts(selectedFilter: .recent)
////                        }
//                        if selectedFilter == .top {
//                            feedVM.getPosts(selectedFilter: .top)
//                        } else if selectedFilter == .hot {
//                            feedVM.getPosts(selectedFilter: .hot)
//                        } else if selectedFilter == .recent {
//                            feedVM.getPosts(selectedFilter: .recent)
//                        }
////                        feedVM.getPostsAlamofire(selectedFilter: selectedFilter)
//                    }
//                }
//            }
//            .background(Color(UIColor.systemGroupedBackground))
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .ignoresSafeArea(.all, edges: .bottom)
//
//            // NewPost Sheet
//            Button {
//                feedVM.isShowingNewPostSheet.toggle()
//            } label: {
//                Image("BouncingBall")
//                    .resizable()
//                    .renderingMode(.template)
//                    .frame(width: 50, height: 50)
//                    .padding()
//                    .foregroundColor(Color(UIColor.tertiarySystemBackground))
//                    .background(Color(UIColor.label))
//                    .clipShape(Circle())
//                    .padding()
//                    .shadow(radius: 10)
//            }
//        }
//    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
//        FeedView(school: .constant("Boston University"), selectedFilter: .hot, postSettingsVM: PostSettingsViewModel())
        FeedView(school: .constant("Boston University"), postSettingsVM: PostSettingsViewModel())
    }
}
