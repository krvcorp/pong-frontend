import SwiftUI
import AlertToast
import ActivityIndicatorView

struct MainTabView: View {
    @Binding var showMenu : Bool
    
    @StateObject var dataManager = DataManager.shared
    @EnvironmentObject private var mainTabVM : MainTabViewModel
    
    @State var itemSelected: Int = 1
    @State var isCustomItemSelected: Bool = false
    
    var body: some View {
        // MARK: If app is loading
        if dataManager.isAppLoading {
            HStack {
                Spacer()
                
                VStack {
                    if !dataManager.errorDetected {
                        Image("PongTextLogo")
                        
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
        }
        // MARK: If app is loaded
        else {
            ZStack(alignment: .bottom) {
                TabView(selection: $itemSelected) {
                    
                    // MARK: Feed
                    FeedView(showMenu: $showMenu).equatable()
                        .gesture(DragGesture())
                        .tag(1)
                    
                    // MARK: Leaderboard
                    LeaderboardView()
                        .gesture(DragGesture())
                        .tag(2)
                    
                    // MARK: Notifications
                    NotificationsView()
                        .gesture(DragGesture())
                        .tag(4)
                    
                    // MARK: Profile
                    ProfileView()
                        .gesture(DragGesture())
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // MARK: TabBar Overlay
                tabBarOverlay
            }
            .accentColor(Color.pongLabel)
            // MARK: New Post Sheet
            .fullScreenCover(isPresented: $isCustomItemSelected) {
                NewPostView(mainTabVM: mainTabVM)
                    .environmentObject(dataManager)
            }
            // MARK: Polling Logic
            .onReceive(dataManager.timer) { _ in
                if dataManager.timePassed % 5 != 0 {
                    dataManager.timePassed += 1
                }
                else {
//                    dataManager.getConversations()
                    dataManager.timePassed += 1
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onChange(of: MainTabViewModel.shared.newPostDetected) { newValue in
                DispatchQueue.main.async {
                    itemSelected = 1
                    isCustomItemSelected = false
                }
            }
        }
    }
    
    // MARK: CustomTabBar
    var tabBarOverlay : some View {
        VStack {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            LazyVGrid(columns: columns, spacing: 20) {
                // MARK: FeedView
                VStack {
                    Image("home")
                        .font(.system(size: 25))
                        .foregroundColor(itemSelected == 1 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                }
                .background(Color.pongSystemBackground)
                .onTapGesture {
                    DispatchQueue.main.async {
                        if itemSelected == 1 {
                            mainTabVM.scrollToTop.toggle()
                        } else {
                            itemSelected = 1
                        }
                    }
                }
                
                // MARK: Stats and Leaderboard
                VStack {
                    Image("trophy")
                        .font(.system(size: 25))
                        .foregroundColor(itemSelected == 2 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                }
                .background(Color.pongSystemBackground)
                .onTapGesture {
                    DispatchQueue.main.async {
                        itemSelected = 2
                    }
                }
                
                // MARK: NewPostView which is a red circle with a white plus sign
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 55))
                    .foregroundStyle(Color.pongSystemWhite, Color.pongAccent)
                    .padding(.bottom)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            isCustomItemSelected.toggle()
                        }
                    }
                
                //MARK: Notifications
                VStack {
                    Image("bell")
                        .font(.system(size: 25))
                        .foregroundColor(itemSelected == 4 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                }
                .background(Color.pongSystemBackground)
                .onTapGesture {
                    DispatchQueue.main.async {
                        itemSelected = 4
                    }
                }
                
                //MARK: Profile
                VStack {
                    Image("person")
                        .font(.system(size: 25))
                        .foregroundColor(itemSelected == 5 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                }
                .background(Color.pongSystemBackground)
                .onTapGesture {
                    DispatchQueue.main.async {
                        itemSelected = 5
                    }
                }
            }
            .frame(width: UIScreen.screenWidth, height: 50)
            .background(Color.pongSystemBackground.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5))
        }
    }
}
