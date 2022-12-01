import SwiftUI
import Introspect
import AlertToast

struct FeedView: View, Equatable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @Namespace var namespace
    
    @Binding var showMenu : Bool
    @EnvironmentObject var mainTabVM : MainTabViewModel
    
    @StateObject var dataManager : DataManager = DataManager.shared
    @State var hotPosts = DataManager.shared.hotPosts
    @State var topPosts = DataManager.shared.topPosts
    @State var recentPosts = DataManager.shared.recentPosts
    
    @StateObject var feedVM = FeedViewModel()
    @StateObject var notificationsManager = NotificationsManager.shared
    
    @State var selectedFeedFilter : FeedFilter = .hot
    @State var selectedTopFilter : TopFilter = .all
    
    var body: some View {
        let _ = print("DEBUG: FeedView.build")
        TabView(selection: $selectedFeedFilter) {
            ForEach(FeedFilter.allCases, id: \.self) { tab in
                customFeedStack(filter: selectedFeedFilter, tab: tab)
                    .tag(tab)
            }
            .background(Color.pongSecondarySystemBackground)
        }
        // this stores posts into local state variables, and as values change in datamanager, changes are reflected on UI
        .onAppear {
            self.hotPosts = DataManager.shared.hotPosts
            self.topPosts = DataManager.shared.topPosts
            self.recentPosts = DataManager.shared.recentPosts
        }
        .onChange(of: DataManager.shared.hotPosts) { newValue in
            DispatchQueue.main.async {
                self.hotPosts = DataManager.shared.hotPosts
            }
        }
        .onChange(of: DataManager.shared.topPosts) { newValue in
            DispatchQueue.main.async {
                self.topPosts = DataManager.shared.topPosts
            }
        }
        .onChange(of: DataManager.shared.recentPosts) { newValue in
            DispatchQueue.main.async {
                self.recentPosts = DataManager.shared.recentPosts
            }
        }
        .background(Color.pongSecondarySystemBackground)
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
                    Text("pong")
                        .bold()
                        .font(.title3)
                }
                .disabled(true)
                .foregroundColor(Color.pongLabel)
            }

            ToolbarItem(placement: .principal) {
                toolbarPickerComponent
            }

            ToolbarItem {
                HStack(spacing: 0) {
                    NavigationLink(destination: MessageRosterView(), isActive: $mainTabVM.openConversationsDetected) {
                        if dataManager.conversations.contains(where: {$0.unreadCount > 0}) {
                            ZStack(alignment: .topTrailing) {
                                Image("bubble.dots.left")
                                Circle()
                                    .fill(.red)
                                    .frame(width: 7, height: 7)
                            }
                        } else {
                            Image("bubble.dots.left")
                        }
                    }
                    .isDetailLink(false)
                }
            }
        }
        .environmentObject(feedVM)
        .onChange(of: mainTabVM.newPostDetected, perform: { change in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
                selectedFeedFilter = .recent

            }
            
            feedVM.paginatePostsReset(selectedFeedFilter: .recent, dataManager: dataManager, selectedTopFilter: selectedTopFilter) { successResponse in
                
            }
        })
        .accentColor(Color.pongLabel)
    }
    
    
    // MARK: ToolbarPickerComponent
    /// The filter bar that allows the user to tap on top, hot, or recent
    var toolbarPickerComponent : some View {
        HStack(spacing: 15) {
            ForEach(FeedFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedFeedFilter = filter
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(filter.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(selectedFeedFilter == filter ? Color.pongAccent : Color.pongLabel)
                        
                        Spacer()
                        
                        if selectedFeedFilter == filter {
                            Color.pongAccent
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "underline",
                                                       in: namespace,
                                                       properties: .frame)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                    .animation(.spring(), value: selectedFeedFilter)
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
            
            ProgressView()
                .foregroundColor(Color.pongLabel)
            
            Spacer()
        }
        .background(Color.pongSystemBackground)
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
                        
                        ForEach(TopFilter.allCases, id: \.id) { filter in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                selectedTopFilter = filter
                            } label: {
                                Text(filter.title)
                                    .font(.subheadline.bold())
                                    .padding(.vertical, 5)
                                    .frame(width: (UIScreen.screenWidth) / 4)
                                    .foregroundColor(selectedTopFilter == filter ? Color.pongLabel : Color.pongLightGray)
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 3).foregroundColor(selectedTopFilter == filter ? Color.pongLabel : Color.pongLightGray))
                                    .background(Color.pongSystemBackground)
                                    .cornerRadius(15)
                            }
                        }
                        
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                    .onChange(of: selectedTopFilter) { newValue in
                        feedVM.topFilterLoading = true
                        
                        feedVM.paginatePostsReset(selectedFeedFilter: .top, dataManager: dataManager, selectedTopFilter: selectedTopFilter) { successResponse in
                            DispatchQueue.main.async {
                                feedVM.topFilterLoading = false
                            }
                        }
                    }
                    
                    if !feedVM.topFilterLoading {
                        ForEach($topPosts, id: \.self) { $post in
                            CustomListDivider()
                            
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.pongSystemBackground)
                        }
                        .listRowInsets(EdgeInsets())
                        
                        CustomListDivider()
                        
                        reachedBottomComponent
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                            .onAppear() {
                                feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                            }
                    }
                    else {
                        loadingComponent
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    
                    
                    if !feedVM.finishedTop && !feedVM.topFilterLoading {
                    }
                }
                // MARK: HOT
                else if tab == .hot {
                    ForEach($hotPosts, id: \.id) { $post in
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    CustomListDivider()
                    
                    if !feedVM.finishedHot {
                        reachedBottomComponent
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                            .onAppear() {
                                feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                            }
                    }
                }
                
                // MARK: RECENT
                else if tab == .recent {
                    ForEach($recentPosts, id: \.id) { $post in
                        CustomListDivider()

                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    CustomListDivider()
                    
                    if !feedVM.finishedRecent {
                        reachedBottomComponent
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                            .onAppear() {
                                feedVM.paginatePosts(selectedFeedFilter: tab, dataManager: dataManager)
                            }
                    }
                }
                
                Rectangle()
                    .fill(Color.pongSystemBackground)
                    .listRowBackground(Color.pongSystemBackground)
                    .frame(minHeight: 150)
                    .listRowSeparator(.hidden)
            }
            .scrollContentBackgroundCompat()
            .background(Color.pongSystemBackground)
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
            // MARK: Refreshable
            .refreshable{
                feedVM.paginatePostsReset(selectedFeedFilter: selectedFeedFilter, dataManager: dataManager, selectedTopFilter: selectedTopFilter) { successResponse in
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    var loadingComponent: some View {
        HStack (alignment: .center) {
            Spacer()
            
            ProgressView()
                .foregroundColor(Color.pongLabel)
            
            Spacer()
        }
    }
    
    static func == (lhs: FeedView, rhs: FeedView) -> Bool {
        // << return yes on view properties which identifies that the
        // view is equal and should not be refreshed (ie. `body` is not rebuilt)
        return lhs.topPosts == rhs.topPosts && lhs.hotPosts == rhs.hotPosts && lhs.recentPosts == rhs.recentPosts
    }
}
