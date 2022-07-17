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
    @StateObject private var feedVM = FeedViewModel()
    @State private var isRefreshing = false
    @State private var offset = CGSize.zero
    @State private var newPost = false

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
            TabView(selection: $selectedFilter) {
                ForEach(FeedFilterViewModel.allCases, id: \.self) { view in
                    ScrollView {
                        ScrollViewReader { scrollReader in
                            
                            // pull to refresh component
                            PullToRefresh(feedVM: feedVM, selectedFilter: $selectedFilter, coordinateSpaceName: "pullToRefresh")
                            
                            // actual stack of post bubbles
                            LazyVStack {
                                // top
                                if view == .top {
                                    ForEach(feedVM.topPosts) { post in
                                        PostBubble(post: post, expanded: false)
                                    }
                                }
                                
                                
                                // hot
                                else if view == .hot {
                                    ForEach(feedVM.hotPosts) { post in
                                        PostBubble(post: post, expanded: false)
                                    }
                                }
                                
                                // recent
                                else if view == .recent {
                                    ForEach(feedVM.recentPosts) { post in
                                        PostBubble(post: post, expanded: false)
                                    }
                                }
                                
                                // default
                                else {
                                    ForEach(feedVM.hotPosts) { post in
                                        PostBubble(post: post, expanded: false)
                                    }
                                }
                            }
                            .coordinateSpace(name: "pullToRefresh")
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
                }
            }
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

// INVESTIGATE DISTANCE TO DRAG
struct PullToRefresh: View {
    @ObservedObject var feedVM : FeedViewModel
    @Binding var selectedFilter : FeedFilterViewModel
    var coordinateSpaceName: String
    typealias FinishedDownload = () -> ()
    
    @State var needRefresh: Bool = false
    
    func onRefresh(completed: FinishedDownload) {
       // Code for function that needs to complete
        feedVM.getPosts(selectedFilter: selectedFilter)
        completed()
    }
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).maxY > 200) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                        onRefresh { () -> () in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Put your code which should be executed with a delay here
                                needRefresh = false
                            }
                        }
                    }
            }
            
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
//                    Image(systemName: "arrow.down").id("top")
                }
                Spacer().id("top")
            }
        }.padding(needRefresh ? .bottom : .top, needRefresh ? 25 : -50)
    }
}


