import SwiftUI

struct MainTabView: View {
    @ObservedObject private var mainTabVM = MainTabViewModel(initialIndex: 1, customItemIndex: 3)
    @StateObject private var scrollToTopHelper = ScrollToTopHelper()
    
    var handler: Binding<Int> { Binding(
        get: {
            self.mainTabVM.itemSelected
        },
        set: {
            // add logic to trigger scroll to top
            if $0 == self.mainTabVM.itemSelected {
                if self.mainTabVM.itemSelected == 1 {
                    self.scrollToTopHelper.trigger.toggle()
                } else {
                    print("DEBUG: not feed")
                }

                
            }
            self.mainTabVM.itemSelected = $0
        }
    )}
    
    var body: some View {
        TabView(selection: handler) {
            // MARK: FeedView
            FeedView(newPostDetected: $mainTabVM.newPostDetected)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
                .tag(1)
                .environmentObject(scrollToTopHelper)
            
            // MARK: Stats and Leaderboard
            LeaderboardView()
                .tabItem{
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
                .tag(2)

            // MARK: NewPostView
            NewPostView(mainTabVM: MainTabViewModel(initialIndex: 1, customItemIndex: 1))
                .tabItem {
                    Image(systemName: "arrowshape.bounce.right.fill")
                }
                .tag(3)
            
            // MARK: NotificationsView
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .tag(4)

            // MARK: ProfileView
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person")
                }
                .tag(5)
        }
        // MARK: New Post Sheet
        .sheet(isPresented: $mainTabVM.isCustomItemSelected) {
            NewPostView(mainTabVM: mainTabVM)
        }
    }
}
