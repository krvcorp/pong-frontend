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
    @Environment(\.refresh) private var refresh   // << refreshable injected !!
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
                            PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                                print("Refresh")
                                api.getPosts()
                            }
                            // actual stack of post bubbles
                            LazyVStack {
                                ForEach(api.posts) { post in
                                    PostBubble(post: post, expanded: false)
                                }
                            }
                            .coordinateSpace(name: "pullToRefresh")
                            .onAppear {
                                api.getPosts()
                            }
                            .onChange(of: newPost, perform: { value in
                                print("DEBUG: switch and scroll")
                                selectedFilter = .recent
                                scrollReader.scrollTo("top") // scrolls to component with id "top" which is the down arrow withing PullToRefresh
                                newPost = false
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
    }
}

// investigate distance to drag
struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).maxY > 200) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 150) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.down").id("top")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}


