import SwiftUI
import Introspect
import AlertToast

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @EnvironmentObject var dataManager : DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject var feedVM = FeedViewModel()
    @Binding var newPostDetected : Bool
    @Binding var showMenu : Bool
    
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
            // Toolbar
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        print("DEBUG: Show Menu")
//                        withAnimation {
//                            showMenu.toggle()
//                        }
//                    } label: {
//                        Image(systemName: "line.horizontal.3")
//                            .imageScale(.large)
//                    }
//                }
                
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
//            .introspectNavigationController { navigationController in
//                let navigationBarAppearance = UINavigationBarAppearance()
//                navigationBarAppearance.configureWithOpaqueBackground()
//                
//                navigationController.navigationBar.standardAppearance = navigationBarAppearance
//                navigationController.navigationBar.compactAppearance = navigationBarAppearance
//                navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
//            }
        }
        .environmentObject(feedVM)
        .onChange(of: newPostDetected, perform: { change in
            DispatchQueue.main.async {
                print("DEBUG: NEW POST DETECTED")
                self.presentationMode.wrappedValue.dismiss()
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
                        .shadow(color: SchoolManager.shared.schoolPrimaryColor(), radius: 7.5, x: 0, y: 0)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())

                    } else {
                        HStack{
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
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
                    HStack{
                        Spacer()
                        ForEach(TopFilter.allCases, id: \.self) { filter in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                feedVM.selectedTopFilter = filter
                            } label: {
                                Text(filter.title)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 30)
                            .foregroundColor(Color(UIColor.label))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke().foregroundColor(Color(UIColor.label)))
                        }
                        Spacer()
                    }
                    .listRowBackground(Color(UIColor.systemBackground))
                    .listRowSeparator(.hidden)
                    .onChange(of: feedVM.selectedTopFilter) { newValue in
                        feedVM.paginatePostsReset(selectedFeedFilter: .top, dataManager: dataManager)
                    }
                    
                    ForEach($dataManager.topPosts, id: \.id) { $post in
                        // custom divider
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(UIColor.systemBackground))

                        CustomListDivider()

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
                        reachedBottomComponentAndFinished
                        CustomListDivider()
                    }
                }
                // MARK: HOT
                else if tab == .hot {
                    ForEach($dataManager.hotPosts, id: \.id) { $post in
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(UIColor.systemBackground))

                        CustomListDivider()
                        
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
                        reachedBottomComponentAndFinished
                        CustomListDivider()
                    }
                }
                // MARK: RECENT
                else if tab == .recent {
                    ForEach($dataManager.recentPosts, id: \.id) { $post in
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                feedVM.paginatePostsIfNeeded(post: post, selectedFeedFilter: tab, dataManager: dataManager)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(UIColor.systemBackground))

                        CustomListDivider()
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
                        reachedBottomComponentAndFinished
                        CustomListDivider()
                    }
                }
            }
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
            .onChange(of: newPostDetected, perform: { newValue in
                if dataManager.recentPosts != [] {
                    proxy.scrollTo(dataManager.recentPosts[0].id, anchor: .bottom)
                }
            })
            .refreshable{
                feedVM.paginatePostsReset(selectedFeedFilter: feedVM.selectedFeedFilter, dataManager: dataManager)
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(newPostDetected: .constant(false), showMenu: .constant(false))
    }
}
