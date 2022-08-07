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

    // MARK: init
    init(postSettingsVM: PostSettingsViewModel) {
        self.postSettingsVM = postSettingsVM
    }
    
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
                    if feedVM.hotPostsInitalOpen {
                        print("DEBUG: feedVM.hotPostsInitialOpen \(feedVM.hotPostsInitalOpen)")
                        feedVM.getPosts(selectedFeedFilter: .top)
                        feedVM.getPosts(selectedFeedFilter: .hot)
                        feedVM.getPosts(selectedFeedFilter: .recent)
                    }
                }
                // MARK: Hide navbar
                .navigationBarTitle("\(feedVM.school)")
                .navigationBarHidden(true)

                // MARK: Building Custom Header With Dynamic Tabs
                .background(Color(UIColor.systemGroupedBackground))
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear(perform: gestureManager.addGesture)
                .onDisappear(perform: gestureManager.removeGesture)

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
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .accentColor(Color(UIColor.label))
        // MARK: Delete popup
        .sheet(isPresented: $postSettingsVM.showDeleteConfirmationView) {
            DeleteConfirmationView(postSettingsVM: postSettingsVM)
        }
    }
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customFeedStack(filter: FeedFilter, screenSize : CGSize, tab : FeedFilter)-> some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    if tab == .top {
                        ForEach(feedVM.topPosts, id: \.self) { post in
                            NavigationLink(destination: PostView(post: post)) {
                                PostBubble(post: post, postSettingsVM: postSettingsVM)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    else if tab == .hot {
                        ForEach(feedVM.hotPosts, id: \.self) { post in
                            NavigationLink(destination: PostView(post: post)) {
                                PostBubble(post: post, postSettingsVM: postSettingsVM)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    else if tab == .recent {
                        ForEach(feedVM.recentPosts, id: \.self) { post in
                            NavigationLink(destination: PostView(post: post)) {
                                PostBubble(post: post, postSettingsVM: postSettingsVM)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.top, feedVM.headerHeight - 15)
                .offsetY { previous, current in
                    // MARK: Moving Header Based On Direction Scroll
                    if previous > current{
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
            }
        }
        .ignoresSafeArea()
        .offsetX { value in
            // MARK: Calculating Offset With The Help Of Currently Active Tab
            if feedVM.selectedFeedFilter == tab && !feedVM.tabviewIsTapped {
                // To Keep Track of Total Offset
                // Here is a Trick, Simply Multiply Offset With (Width Of the Tab View * Current Index)
                feedVM.tabviewOffset = value - (screenSize.width * CGFloat(feedVM.indexOf(tab: tab)))

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

            if value == 0 && feedVM.tabviewIsTapped{
                feedVM.tabviewIsTapped = false
            }

            // What If User Scrolled Fastly When The Offset Don't Reach 0
            // WorkAround: Detecting If User Touch The Screen, then Setting  isTapped to False
            if feedVM.tabviewIsTapped && gestureManager.isInteracting{
                feedVM.tabviewIsTapped = false
            }
        }
    }
    
    // MARK: Custom Header
    @ViewBuilder
    func HeaderView(size: CGSize)->some View{
        VStack {
            // MARK: Former Navbar Components 
            HStack {
                VStack {
                    Text("Boston University")
                        .font(.title).bold()
                }
                
                Spacer()
                
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "message")
                }
            }
            .padding()
            
            // MARK: Picker Component
            DynamicTabHeader(size: size)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .padding(.top, safeArea().top)
        .padding(.bottom, 20)
    }
    
    // MARK: Custom tabbar
    @ViewBuilder
    func DynamicTabHeader(size: CGSize)->some View{
        VStack(alignment: .leading, spacing: 22) {
            // MARK: I'm Going to Show Two Types of Dynamic Tabs
            // MARK: Type 2:
            HStack(spacing: 0){
                ForEach(FeedFilter.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .fontWeight(.semibold)
                        .padding(.vertical,6)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color(UIColor.label))
                    // MARK: Same Technique Followed on Type 1
                    // MARK: For Realistic Tab Change Animation
                    .overlay(alignment: .leading, content: {
                        GeometryReader{_ in
                            HStack(spacing: 0){
                                ForEach(FeedFilter.allCases, id: \.self) { tab in
                                    Text(tab.title)
                                        .fontWeight(.semibold)
                                        .padding(.vertical,6)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .contentShape(Capsule())
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
                            // MARK: Simply Reverse The Offset
                            .offset(x: -feedVM.tabOffset(size: size, padding: 30))
                        }
                        .frame(width: size.width - 30)
                    })
                    .frame(width: (size.width - 30) / CGFloat(FeedFilter.allCases.count))
                    .mask({Capsule()})
                    .offset(x: feedVM.tabOffset(size: size, padding: 30))
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(15)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(postSettingsVM: PostSettingsViewModel())
    }
}
