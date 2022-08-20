import SwiftUI
//import ScalingHeaderScrollView
import Introspect

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    // MARK: ViewModels
    @StateObject var feedVM = FeedViewModel()
    @Binding var newPostDetected : Bool
    
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
                .background(Color(UIColor.systemGroupedBackground))
                // MARK: Building Custom Header With Dynamic Tabs
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // MARK: Hide navbar
                .navigationBarTitle("\(feedVM.school)")
                .navigationBarTitleDisplayMode(.inline)
                // MARK: Toolbar
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
        .onChange(of: newPostDetected, perform: { change in
            DispatchQueue.main.async {
                print("DEBUG: NEW POST DETECTED")
                feedVM.selectedFeedFilter = .recent
                feedVM.getPosts(selectedFeedFilter: .recent)
            }
        })
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
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Tap to try again")
                }
                Spacer()
            }
            .background(Color(UIColor.systemBackground))
            .onAppear() {
                print("DEBUG: Paginate!")
            }
        }
        .refreshable{
            print("DEBUG: Refresh")
            feedVM.getPosts(selectedFeedFilter: feedVM.selectedFeedFilter)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(newPostDetected: .constant(false))
    }
}
