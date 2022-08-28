import SwiftUI
import Introspect
import AlertToast

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var setTabHelper : SetTabHelper
    @EnvironmentObject var dataManager : DataManager
    @StateObject var feedVM = FeedViewModel()
    @Binding var newPostDetected : Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $feedVM.selectedFeedFilter) {
                ForEach(FeedFilter.allCases, id: \.self) { tab in
                    customFeedStack(filter: feedVM.selectedFeedFilter, tab: tab)
                        .tag(tab)
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
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
                feedVM.paginatePostsReset(selectedFeedFilter: .recent, dataManager: dataManager)
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(UIColor.label))
        .toast(isPresenting: $dataManager.removedPost){
            AlertToast(displayMode: .hud, type: .regular, title: dataManager.removedPostMessage)
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
                        .shadow(color: Color(UIColor(named: "PongPrimarySelected")!), radius: 10, x: 0, y: 0)
                        .foregroundColor(Color(UIColor(named: "PongPrimarySelected")!))

                    } else {
                        HStack{
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(Color(UIColor(named: "PongPrimary")!))
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
                // MARK: Top
                if tab == .top {
                    // top filter
                    Menu {
                        ForEach(TopFilter.allCases, id: \.self) { filter in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                feedVM.selectedTopFilter = filter
                            } label: {
                                Text(filter.title)
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(feedVM.selectedTopFilter.title)")
                                .font(.caption.bold())
                            Image(systemName: "chevron.down")
                        }
                        .padding(.top)
                        
                        Spacer()
                    }
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .listRowSeparator(.hidden)
                    .onChange(of: feedVM.selectedTopFilter) { newValue in
                        feedVM.paginatePostsReset(selectedFeedFilter: .top, dataManager: dataManager)
                    }
                    
                    ForEach($dataManager.topPosts, id: \.id) { $post in
                        // custom divider
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                    }
                    
                    if !feedVM.finishedTop {
                        CustomListDivider()
                        
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        }
                    } else {
                        CustomListDivider()
                        
                        reachedBottomComponentAndFinished
                    }
                }
                // MARK: HOT
                else if tab == .hot {
                    ForEach($dataManager.hotPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                        
                    }
                    if !feedVM.finishedHot {
                        CustomListDivider()
                        
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        }
                    } else {
                        CustomListDivider()
                        reachedBottomComponentAndFinished
                    }
                }
                // MARK: RECENT
                else if tab == .recent {
                    ForEach($dataManager.recentPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                    }
                    if !feedVM.finishedRecent {
                        CustomListDivider()
                        Button {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        } label: {
                            reachedBottomComponent
                        }
                        .onAppear() {
                            feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                        }
                    } else {
                        CustomListDivider()
                        reachedBottomComponentAndFinished
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .onChange(of: setTabHelper.trigger, perform: { newValue in
                withAnimation {
                    if tab == .top {
                        proxy.scrollTo(dataManager.topPosts[0].id, anchor: .bottom)
                    } else if tab == .hot {
                        proxy.scrollTo(dataManager.hotPosts[0].id, anchor: .bottom)
                    } else if tab == .recent {
                        proxy.scrollTo(dataManager.recentPosts[0].id, anchor: .bottom)
                    }
                }
            })
            .refreshable{
                print("DEBUG: Refresh")
                feedVM.paginatePostsReset(selectedFeedFilter: feedVM.selectedFeedFilter, dataManager: dataManager)
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(newPostDetected: .constant(false))
    }
}
