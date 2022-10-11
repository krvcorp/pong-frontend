import SwiftUI
import AlertToast
import ActivityIndicatorView

struct MainTabView: View {
    @EnvironmentObject var appState : AppState
    @StateObject var dataManager = DataManager()
    @EnvironmentObject private var mainTabVM : MainTabViewModel
    @Binding var showMenu : Bool
    
    var handler: Binding<Int> { Binding(
        get: {
            self.mainTabVM.itemSelected
        },
        set: {
            // add logic to trigger scroll to top
            if $0 == self.mainTabVM.itemSelected {
                if self.mainTabVM.itemSelected == 1 {
                    self.mainTabVM.scrollToTop.toggle()
                } else {
                    print("DEBUG: not feed")
                }
            }
            self.mainTabVM.itemSelected = $0
        }
    )}
    
    var body: some View {
        // MARK: If app is loading
        if dataManager.isAppLoading {
            HStack {
                Spacer()
                
                VStack {
                    if !dataManager.errorDetected {
                        ActivityIndicatorView(isVisible: $dataManager.isAppLoading, type: .equalizer(count: 8))
                            .frame(width: 50.0, height: 50.0)
                            .onAppear {
                                dataManager.loadStartupState()
                            }
                    } else {
                        Button {
                            dataManager.loadStartupState()
                        } label: {
                            VStack {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.screenWidth / 4)
                                Text("Try Again!")
                            }

                        }
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                    }
                }

                Spacer()
            }
            .toast(isPresenting: $dataManager.errorDetected){
                AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
            }
        }
        // MARK: If app is loaded
        else {
            TabView(selection: handler) {
                // MARK: FeedView
                FeedView(showMenu: $showMenu)
                    .tabItem{
                        Image(systemName: "house")
                    }
                    .tag(1)
                
                // MARK: Stats and Leaderboard
                LeaderboardView()
                    .tabItem{
                        Image(systemName: "chart.bar.xaxis")
                    }
                    .tag(2)

                // MARK: NewPostView
                NewPostView(mainTabVM: MainTabViewModel(initialIndex: 0, customItemIndex: 0))
                    .tabItem {
                        Image(systemName: "arrowshape.bounce.right.fill")
                    }
                    .tag(3)
                
                //MARK: Notifications
                NotificationsView()
                    .tabItem{
                        Image(systemName: "bell")
                    }
                    .tag(4)
                

                // MARK: ProfileView
                ProfileView()
                    .tabItem{
                        Image(systemName: "person")
                    }
                    .tag(5)
            }
            .environmentObject(dataManager)
            .accentColor(SchoolManager.shared.schoolPrimaryColor())
            // MARK: New Post Sheet
            .sheet(isPresented: $mainTabVM.isCustomItemSelected) {
                NewPostView(mainTabVM: mainTabVM)
            }
            .toast(isPresenting: $dataManager.errorDetected){
                AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
            }
        }
    }
}
