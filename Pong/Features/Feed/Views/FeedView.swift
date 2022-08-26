import SwiftUI
import Introspect
import AlertToast

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scrollToTopHelper : ScrollToTopHelper
    @StateObject var feedVM = FeedViewModel()
    @Binding var newPostDetected : Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $feedVM.selectedFeedFilter) {
                ForEach(FeedFilter.allCases, id: \.self) { tab in
                    customFeedStack(filter: feedVM.selectedFeedFilter, tab: tab)
                        .tag(tab)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Hide navbar
            .navigationBarTitle("\(feedVM.school)")
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        MessageRosterView()
                    } label: {
                        Image(systemName: "message")
                    }
                }
                ToolbarItem(placement: .principal) {
                    toolbarPickerComponent
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
        .environmentObject(feedVM)
        .onChange(of: newPostDetected, perform: { change in
            DispatchQueue.main.async {
                print("DEBUG: NEW POST DETECTED")
                feedVM.selectedFeedFilter = .recent
                feedVM.paginatePostsReset(selectedFeedFilter: .recent)
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(UIColor.label))
        .toast(isPresenting: $feedVM.removedPost){
            AlertToast(displayMode: .hud, type: .regular, title: feedVM.removedPostType)
        }
    }
    
    // component for toolbar picker
    var toolbarPickerComponent : some View {
        HStack {
            ForEach(FeedFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    feedVM.selectedFeedFilter = filter
                } label: {
                    if feedVM.selectedFeedFilter == filter {
                        HStack {
                            Image(systemName: filter.filledImageName)
                            Text(filter.title)
                                .bold()
                        }
                        .shadow(color: colorScheme == .dark ? Color.poshGold : Color.poshDarkPurple, radius: 10, x: 0, y: 0)
                        .foregroundColor(colorScheme == .dark ? Color.poshGold : Color.poshDarkPurple)

                    } else {
                        HStack{
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(colorScheme == .dark ? Color.poshGold : Color.poshBlue)
                    }
                }
            }
        }
    }
    
    // Component at the bottom of the list
    var reachedBottomComponent : some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "arrow.clockwise")
                Text("Tap to try again")
            }
            Spacer()
        }
    }
    
    // Component at the bottom of the list that shows when all posts have been fetched
    var reachedBottomComponentAndFinished : some View {
        Text("There's nothing left! Scroll to top and refresh!")
    }
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customFeedStack(filter: FeedFilter, tab : FeedFilter) -> some View {
        ScrollViewReader { proxy in
            List {
                if tab == .top {
                    Menu {
                        ForEach(TopFilter.allCases, id: \.self) { filter in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
                                .onAppear {
                                    feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab)
                                }
                        }
                    }
                    
                    if !feedVM.finishedTop {
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        }
                    } else {
                        reachedBottomComponentAndFinished
                    }
                }
                else if tab == .hot {
                    ForEach($feedVM.hotPosts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab)
                                }
                        }
                    }
                    if !feedVM.finishedHot {
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        }
                    } else {
                        reachedBottomComponentAndFinished
                    }
                }
                else if tab == .recent {
                    ForEach($feedVM.recentPosts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab)
                                }
                        }
                    }
                    if !feedVM.finishedRecent {
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab)
                        }
                    } else {
                        reachedBottomComponentAndFinished
                    }
                }
            }
            .onChange(of: scrollToTopHelper.trigger, perform: { newValue in
                withAnimation {
                    if tab == .top {
                        proxy.scrollTo(feedVM.topPosts[0].id, anchor: .bottom)
                    } else if tab == .hot {
                        proxy.scrollTo(feedVM.hotPosts[0].id, anchor: .bottom)
                    } else if tab == .recent {
                        proxy.scrollTo(feedVM.recentPosts[0].id, anchor: .bottom)
                    }
                }
            })
            .refreshable{
                print("DEBUG: Refresh")
                feedVM.paginatePostsReset(selectedFeedFilter: feedVM.selectedFeedFilter)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(newPostDetected: .constant(false))
    }
}
