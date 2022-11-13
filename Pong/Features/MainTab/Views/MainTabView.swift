import SwiftUI
import AlertToast
import ActivityIndicatorView

struct MainTabView: View {
    @EnvironmentObject var appState : AppState
    @StateObject var dataManager = DataManager.shared
    @EnvironmentObject private var mainTabVM : MainTabViewModel
    @Binding var showMenu : Bool
    
    var body: some View {
        // MARK: If app is loading
        if dataManager.isAppLoading {
            HStack {
                Spacer()
                
                VStack {
                    if !dataManager.errorDetected {
                        Image("PongTextLogo")
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
            NavigationView {
                // create a custom tab view with a custom tab bar using a zstack
                ZStack(alignment: .bottom) {
                    // if statements to check what selection is on to show a specific view
                    if mainTabVM.itemSelected == 1 {
                        FeedView(showMenu: $showMenu)
                    } else if mainTabVM.itemSelected == 2 {
                        LeaderboardView()
                    } else if mainTabVM.itemSelected == 3 {
                        NewPostView(mainTabVM: mainTabVM)
                    } else if mainTabVM.itemSelected == 4 {
                        NotificationsView()
                    } else if mainTabVM.itemSelected == 5 {
                        ProfileView()
                    }
                    
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]

                    LazyVGrid(columns: columns, spacing: 20) {
                        // MARK: FeedView
                        Button(action: {
                            DispatchQueue.main.async {
                                if mainTabVM.itemSelected == 1 {
                                    mainTabVM.scrollToTop.toggle()
                                } else {
                                    mainTabVM.itemSelected = 1
                                }
                            }
                        }) {
                            VStack {
                                Image("home")
                                    .font(.system(size: 50))
                                    .foregroundColor(mainTabVM.itemSelected == 1 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                            }
                        }
                        
                        // MARK: Stats and Leaderboard
                        Button(action: {
                            DispatchQueue.main.async {
                                mainTabVM.itemSelected = 2
                            }
                        }) {
                            VStack {
                                Image("trophy")
                                    .font(.system(size: 50))
                                    .foregroundColor(mainTabVM.itemSelected == 2 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                            }
                        }
                        
                        // MARK: NewPostView which is a red circle with a white plus sign
                        Button(action: {
                            DispatchQueue.main.async {
                                mainTabVM.itemSelected = 3
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(Color.pongSystemWhite, Color.pongAccent)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom)
                        
                        //MARK: Notifications
                        Button(action: {
                            DispatchQueue.main.async {
                                mainTabVM.itemSelected = 4
                            }
                        }) {
                            VStack {
                                Image("bell")
                                    .font(.system(size: 50))
                                    .foregroundColor(mainTabVM.itemSelected == 4 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                            }
                        }
                        
                        //MARK: Profile
                        Button(action: {
                            DispatchQueue.main.async {
                                mainTabVM.itemSelected = 5
                            }
                        }) {
                            VStack {
                                Image("person")
                                    .font(.system(size: 50))
                                    .foregroundColor(mainTabVM.itemSelected == 5 ? Color.pongAccent : Color(UIColor.secondaryLabel))
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth, height: 50)
                    .background(Color.pongSystemBackground)
                    .ignoresSafeArea(.all, edges: .bottom)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .environmentObject(dataManager)
            .accentColor(Color.pongLabel)
            // MARK: New Post Sheet
            .sheet(isPresented: $mainTabVM.isCustomItemSelected) {
                NewPostView(mainTabVM: mainTabVM)
                    .environmentObject(dataManager)
            }
            .toast(isPresenting: $dataManager.errorDetected){
                AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
            }
        }
    }
}
