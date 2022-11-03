import SwiftUI
import Introspect
import AlertToast

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @EnvironmentObject var dataManager : DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject var feedVM = FeedViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.shared
    @Binding var showMenu : Bool
    
    // MARK: Conversation
    @State private var isLinkActive = false
    @State private var conversation = defaultConversation
    
    @Namespace var namespace
    
    var body: some View {
        NavigationView {
            TabView(selection: $feedVM.selectedFeedFilter) {
                ForEach(FeedFilter.allCases, id: \.self) { tab in
                    customFeedStack(filter: feedVM.selectedFeedFilter, tab: tab)
                        .tag(tab)
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            .background(Color(UIColor.secondarySystemBackground))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // Hide navbar
            .navigationBarTitle("\(feedVM.school)")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Toolbar
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button() {
                        
                    }
                    label: {
                        Text("BU")
                            .bold()
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    toolbarPickerComponent
                }
                
                ToolbarItem {
                    HStack(spacing: 0) {
                        NavigationLink(destination: MessageView(conversation: $conversation), isActive: $isLinkActive) { EmptyView().opacity(0) }.opacity(0)
                        
                        NavigationLink(destination: MessageRosterView(), isActive: $mainTabVM.openConversationsDetected) {
                            if dataManager.conversations.contains(where: {!$0.read}) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "envelope")
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 7, height: 7)
                                }
                            } else {
                                Image(systemName: "envelope")
                            }
                        }
                    }
                }
            }
        }
        .environmentObject(feedVM)
        .onChange(of: mainTabVM.newPostDetected, perform: { change in
            DispatchQueue.main.async {
                print("DEBUG: NEW POST DETECTED")
                self.presentationMode.wrappedValue.dismiss()
                feedVM.selectedFeedFilter = .recent
                feedVM.paginatePostsReset(selectedFeedFilter: .recent, dataManager: dataManager)
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.pongLabel)
        .toast(isPresenting: $dataManager.removedPost){
            AlertToast(displayMode: .hud, type: .regular, title: dataManager.removedPostMessage)
        }
        .toast(isPresenting: $dataManager.errorDetected) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
        }
    }
    
    
    // MARK: ToolbarPickerComponent
    /// The filter bar that allows the user to tap on top, hot, or recent
    var toolbarPickerComponent : some View {
        HStack(spacing: 15) {
            ForEach(FeedFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    feedVM.selectedFeedFilter = filter
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(filter.title)
                            .font(.subheadline.bold())
                            .foregroundColor(feedVM.selectedFeedFilter == filter ? Color.pongAccent : Color.pongSecondaryText)
                        
                        Spacer()
                        
                        if feedVM.selectedFeedFilter == filter {
                            Color.pongAccent
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "underline",
                                                       in: namespace,
                                                       properties: .frame)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                    .animation(.spring(), value: feedVM.selectedFeedFilter)
                }
            }
        }
        .padding(0)
    }
    
    // MARK: ReachedBottomComponent
    /// If the user somehow reaches the bottom of the feed and the pagination doesn't fire, there is another component that triggers on appear to paginate and allows the user to tap on in order to paginate again
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
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customFeedStack(filter: FeedFilter, tab : FeedFilter) -> some View {
        ScrollViewReader { proxy in
            List {
                // MARK: TOP
                if tab == .top {
                    //MARK: Top filter bar component
                    HStack {
                        Spacer()
                        
                        ForEach(TopFilter.allCases, id: \.self) { filter in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                feedVM.selectedTopFilter = filter
                            } label: {
                                Text(filter.title)
                                    .font(.subheadline.bold())
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 30)
                                    .foregroundColor(feedVM.selectedTopFilter == filter ? Color.pongSystemBackground : Color(UIColor.label))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke().foregroundColor(Color(UIColor.label)))
                                    .background(feedVM.selectedTopFilter == filter ? Color(UIColor.label) : Color.pongSystemBackground)
                                    .cornerRadius(15)
                            }
                        }
                        
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.pongSecondarySystemBackground)
                    .listRowSeparator(.hidden)
                    .onChange(of: feedVM.selectedTopFilter) { newValue in
                        feedVM.paginatePostsReset(selectedFeedFilter: .top, dataManager: dataManager)
                    }
                    
                    ForEach($dataManager.topPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post, isLinkActive: $isLinkActive, conversation: $conversation)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    .listRowInsets(EdgeInsets())
                    
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
                    }
                }
                // MARK: HOT
                else if tab == .hot {
                    ForEach($dataManager.hotPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post, isLinkActive: $isLinkActive, conversation: $conversation)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    .listRowInsets(EdgeInsets())
                    
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
                    }
                }
                
                // MARK: RECENT
                else if tab == .recent {
                    ForEach($dataManager.recentPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post, isLinkActive: $isLinkActive, conversation: $conversation)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    .listRowInsets(EdgeInsets())
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
                    }
                }
            }
            .scrollContentBackgroundCompat()
            .background(Color.pongSecondarySystemBackground)
            .environment(\.defaultMinListRowHeight, 0)
            .onChange(of: mainTabVM.scrollToTop, perform: { newValue in
                withAnimation {
                    if tab == .top {
                        if dataManager.topPosts != [] {
                            proxy.scrollTo(dataManager.topPosts[0].id, anchor: .bottom)
                        }
                    } else if tab == .hot {
                        if dataManager.hotPosts != [] {
                            proxy.scrollTo(dataManager.hotPosts[0].id, anchor: .bottom)
                        }
                    } else if tab == .recent {
                        if dataManager.recentPosts != [] {
                            proxy.scrollTo(dataManager.recentPosts[0].id, anchor: .bottom)
                        }
                    }
                }
            })
            .onChange(of: mainTabVM.newPostDetected, perform: { newValue in
                if dataManager.recentPosts != [] {
                    proxy.scrollTo(dataManager.recentPosts[0].id, anchor: .bottom)
                }
            })
//            .onReceive(feedVM.timer) { _ in
//                if feedVM.timePassed % 5 != 0 {
//                    feedVM.timePassed += 1
//                }
//                else {
//                    feedVM.getConversations(dataManager: dataManager)
//                    feedVM.timePassed += 1
//                }
//            }
//            .onAppear {
//                feedVM.getConversations(dataManager: dataManager)
//                self.feedVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
//            }
//            .onDisappear {
//                self.feedVM.timer.upstream.connect().cancel()
//            }
            .refreshable{
                feedVM.paginatePostsReset(selectedFeedFilter: feedVM.selectedFeedFilter, dataManager: dataManager)
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(showMenu: .constant(false))
    }
}
