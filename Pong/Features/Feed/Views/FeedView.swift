//
//  FeedView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI
import ScalingHeaderScrollView

struct FeedView: View {
    // MARK: Gesture Manager
    @StateObject var gestureManager: InteractionManager = .init()
    
    // MARK: ViewModels
    @StateObject var feedVM = FeedViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                let screenSize = proxy.size
                TabView(selection: $feedVM.selectedFeedFilter) {
                    ForEach(FeedFilter.allCases, id: \.self) { tab in
                        customFeedStack(filter: feedVM.selectedFeedFilter, screenSize: screenSize, tab: tab)
                            .tag(tab)
                    }
                }
                // MARK: OnAppear fetch all posts
                .onAppear {
                    if feedVM.InitalOpen {
                        print("DEBUG: feedVM.hotPostsInitialOpen \(feedVM.InitalOpen)")
                        feedVM.getPosts(selectedFeedFilter: .top)
                        feedVM.getPosts(selectedFeedFilter: .hot)
                        feedVM.getPosts(selectedFeedFilter: .recent)
                    }
                }
                // MARK: Debug everytime a filter is changed the column is refetched
                .onChange(of: feedVM.selectedFeedFilter) { newFilter in
                    feedVM.getPosts(selectedFeedFilter: newFilter)
                    feedVM.selectedFeedFilter = newFilter
                }
                .background(Color(UIColor.systemGroupedBackground))
                // MARK: Building Custom Header With Dynamic Tabs
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // MARK: Hide navbar
                .navigationBarTitle("\(feedVM.school)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        NavigationLink {
                            MessagesView()
                        } label: {
                            Image(systemName: "message")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            ForEach(FeedFilter.allCases, id: \.self) { filter in
                                Button {
                                    feedVM.selectedFeedFilter = filter
                                } label: {
                                    if feedVM.selectedFeedFilter == filter {
                                        HStack {
                                            Image(systemName: filter.imageName)
                                            Text(filter.title)
                                                .bold()
                                        }
                                        .shadow(color: Color.poshGold, radius: 10, x: 0, y: 0)
                                        .foregroundColor(Color.poshGold)

                                    } else {
                                        HStack{
                                            Image(systemName: filter.imageName)
                                            Text(filter.title)
                                        }
                                        .foregroundColor(Color.poshLightGold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .introspectNavigationController { navigationController in
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithOpaqueBackground()
                
                navigationController.navigationBar.standardAppearance = navigationBarAppearance
                navigationController.navigationBar.compactAppearance = navigationBarAppearance
                navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(UIColor.label))
    }
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customFeedStack(filter: FeedFilter, screenSize : CGSize, tab : FeedFilter)-> some View {
        List {
            if tab == .top {
                Menu {
                    ForEach(TopFilter.allCases, id: \.self) { filter in
                        Button {
                            print("DEBUG: ")
                            feedVM.selectedTopFilter = filter
                        } label: {
                            Text(filter.title)
                        }
                    }
                } label: {
                    Spacer()
                    
                    Text("\(feedVM.selectedTopFilter.title)")
                    Image(systemName: "chevron.down")
                    
                    Spacer()
                }
                
                ForEach($feedVM.topPosts, id: \.id) { $post in
                    Section {
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                    }

                }
            }
            else if tab == .hot {
                ForEach($feedVM.hotPosts, id: \.id) { $post in
                    Section {
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            else if tab == .recent {
                ForEach($feedVM.recentPosts, id: \.id) { $post in
                    Section {
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .refreshable{
            print("DEBUG: Refresh")
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
