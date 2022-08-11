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
    @ObservedObject var postSettingsVM: PostSettingsViewModel
    
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
                }
                .background(Color(UIColor.systemGroupedBackground))
                // MARK: Building Custom Header With Dynamic Tabs
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    gestureManager.addGesture()
                }
                .onDisappear {
                    gestureManager.removeGesture()
                }
                // MARK: SwipeHiddenHeader modifiers
                .coordinateSpace(name: "SCROLL")
                .overlay(alignment: .top) {
                    HeaderView(size: screenSize)
                        .anchorPreference(key: HeaderBoundsKey.self, value: .bounds){$0}
                        .overlayPreferenceValue(HeaderBoundsKey.self) { value in
                            GeometryReader { proxy in
                                if let anchor = value {
                                    Color.clear
                                        .onAppear {
                                            // MARK: Retreiving Rect Using Proxy
                                            feedVM.headerHeight = proxy[anchor].height
                                        }
                                }
                            }
                        }
                        .offset(y: -feedVM.headerOffset < feedVM.headerHeight ? feedVM.headerOffset : (feedVM.headerOffset < 0 ? feedVM.headerOffset : 0))
                }
                
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
                }
//                .ignoresSafeArea(.all, edges: .top)
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
                    ForEach($feedVM.topPosts, id: \.id) { $post in
                        PostBubble(post: $post, postSettingsVM: postSettingsVM)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                else if tab == .hot {
                    ForEach($feedVM.hotPosts, id: \.id) { $post in
                        PostBubble(post: $post, postSettingsVM: postSettingsVM)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                else if tab == .recent {
                    ForEach($feedVM.recentPosts, id: \.id) { $post in
                        PostBubble(post: $post, postSettingsVM: postSettingsVM)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.top, feedVM.headerHeight - 15)
            .offsetY { previous, current in
                // MARK: Moving Header Based On Direction Scroll
                if previous > current {
                    // MARK: Up
                    if feedVM.headerDirection != .up && current < 0{
                        feedVM.headerShiftOffset = current - feedVM.headerOffset
                        feedVM.headerDirection = .up
                        feedVM.lastHeaderOffset = feedVM.headerOffset
                    }

                    let offset = current < 0 ? (current - feedVM.headerShiftOffset) : 0
                    // MARK: Checking If It Does Not Goes Over Over Header Height
                    feedVM.headerOffset = (-offset < feedVM.headerHeight ? (offset < 0 ? offset : 0) : -feedVM.headerHeight)
                } else {
                    // MARK: Down
                    if feedVM.headerDirection != .down{
                        feedVM.headerShiftOffset = current
                        feedVM.headerDirection = .down
                        feedVM.lastHeaderOffset = feedVM.headerOffset
                    }

                    let offset = feedVM.lastHeaderOffset + (current - feedVM.headerShiftOffset)
                    feedVM.headerOffset = (offset > 0 ? 0 : offset)
                }
            }
//        .ignoresSafeArea()
        .offsetX { value in
            // MARK: Calculating Offset With The Help Of Currently Active Tab
            if feedVM.selectedFeedFilter == tab && !feedVM.tabviewIsTapped {
                // To Keep Track of Total Offset
                // Here is a Trick, Simply Multiply Offset With (Width Of the Tab View * Current Index)
                feedVM.tabviewOffset = value - (screenSize.width * CGFloat(feedVM.indexOf(tab: tab)))
            }

            if value == 0 && feedVM.tabviewIsTapped{
                feedVM.tabviewIsTapped = false
            }

            // What If User Scrolled Fastly When The Offset Don't Reach 0
            // WorkAround: Detecting If User Touch The Screen, then Setting  isTapped to False
            if feedVM.tabviewIsTapped && gestureManager.isInteracting{
                feedVM.tabviewIsTapped = false
            }
            // MARK: Switching tabs will bring down header view
            if gestureManager.isInteracting {
                withAnimation {
                    feedVM.headerOffset = 0
                    feedVM.headerShiftOffset = 0
                    feedVM.lastHeaderOffset = 0
                    feedVM.headerDirection = .none
                }
            }
        }
    }
    
    // MARK: Custom Header which moves based on scroll
    @ViewBuilder
    func HeaderView(size: CGSize)->some View{
        VStack {
            // MARK: Picker Component
            DynamicTabHeader(size: size)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .padding(.bottom, 20)
        //        .padding(.top, safeArea().top)
    }
    
    // MARK: Custom tabbar
    @ViewBuilder
    func DynamicTabHeader(size: CGSize)->some View{
        VStack(alignment: .leading, spacing: 22) {
            // MARK: Dynamic Tab Type 1: Underline only
            HStack(spacing: 0){
                ForEach(FeedFilter.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .font(.headline.bold())
                        .padding(.vertical,6)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(UIColor.label))
                        .onTapGesture {
                            // MARK: Disabling The TabScrollOffset Detection
                            feedVM.tabviewIsTapped = true
                            // MARK: Updating Tab
                            withAnimation(.easeInOut){
                                // MARK: It Won't Update
                                // Because SwiftUI TabView Quickly Updates The Offset
                                // So Manually Updating It
                                feedVM.selectedFeedFilter = tab
                                // MARK: Since TabView is Not Padded
                                feedVM.tabviewOffset = -(size.width) * CGFloat(feedVM.indexOf(tab: tab))
                            }
                        }
                }
            }
            .background(alignment: .bottomLeading) {
                Capsule()
                    .fill(Color(UIColor.label))
                    .frame(width: (size.width - 30) / CGFloat(FeedFilter.allCases.count), height: 4)
                    .offset(y: 12)
                    .offset(x: feedVM.tabOffset(size: size, padding: 30))
            }
            // MARK: Bubble overlay for tab selection
        }
        // MARK: Remove Background for tracking purposes
//        .background(.red)
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(.horizontal, 15)
        .padding(.bottom, 15)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(postSettingsVM: PostSettingsViewModel())
    }
}
