import SwiftUI
import AlertToast
import PartialSheet

struct ContentView: View {
    @StateObject var appState = AppState.shared
    @StateObject var authManager = AuthManager.authManager
    @StateObject var toastManager = ToastManager.shared
    @StateObject var dataManager = DataManager.shared
    
    @State var showMenu = false
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    // MARK: PostPushNavigationBinding
    var postPushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.postToNavigateTo != nil
        } set: { (newValue) in
            if !newValue {
                appState.postToNavigateTo = nil
            }
        }
    }
    
    // MARK: LeaderboardPushNavigationBinding
    var leaderboardPushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.leaderboard != nil
        } set: { (newValue) in
            if !newValue {
                appState.leaderboard = nil
            }
        }
    }
    
    // MARK: ConversationPushNavigationBinding
    var conversationPushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.conversationToNavigateTo != nil
        } set: { (newValue) in
            if !newValue {
                appState.conversationToNavigateTo = nil
            }
        }
    }
    
    // MARK: Body
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
            }
        
        NavigationView {
            Group {
                if (!authManager.isSignedIn) {
                    EmailVerificationView()
                        .toast(isPresenting: $authManager.signedOutAlert) {
                            AlertToast(displayMode: .hud, type: .regular,  title: "Signed out! See you soon :)")
                        }
                }
                else if (authManager.waitlisted) {
                    WaitlistView()
                        .navigationBarHidden(true)
                }
                else if (!authManager.onboarded) {
                    OnboardingView()
                        .navigationBarHidden(true)
                } else {
                    ZStack(alignment: .leading) {
                        MainTabView(showMenu: self.$showMenu)
                            .offset(x: self.showMenu ? UIScreen.screenWidth/1.5 : 0)
                        
                        HStack {
                            ChooseCommunityView()
                                .frame(width: UIScreen.screenWidth/1.5)
                                .transition(.move(edge: .leading))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                        .shadow(color: Color(UIColor.gray), radius:5, x: -5, y: 0)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .edgesIgnoringSafeArea(.all)
                                )
                            
                            if self.showMenu {
                                Color.white
                                    .opacity(showMenu ? 0.01 : 0)
                                    .onTapGesture {
                                        withAnimation {
                                            self.showMenu = false
                                        }
                                    }
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                        .offset(x: self.showMenu ? 0 : -UIScreen.screenWidth/1.5)
                    }
                    .gesture(drag)
                }
            }
            // MARK: Overlays used for the user tapping on a notification / the user tapped on a shared link
            .overlay(NavigationLink(destination: PostView(post: $appState.post), isActive: postPushNavigationBinding) {
                EmptyView()
            })
            .overlay(NavigationLink(destination: LeaderboardView(), isActive: leaderboardPushNavigationBinding) {
                EmptyView()
            })
            .overlay(NavigationLink(destination: MessageView(conversation: $appState.conversation), isActive: conversationPushNavigationBinding) {
                EmptyView()
            })
            // MARK: Parsing the universal link the user clicked
            .onOpenURL { url in
                print("DEBUG: \(url.absoluteString)")
                let parts = url.absoluteString.split(separator: "/")
                print("DEBUG: \(parts)")
                AppState.shared.readPost(url: String(describing: parts[3])) { success in
                    if success {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                            if !dataManager.isAppLoading {
                                AppState.shared.postToNavigateTo = String(describing: parts[3])
                                timer.invalidate()
                            }
                        }
                    }
                }
            }
        }
        .environmentObject(appState)
        .accentColor(Color.pongAccent)
        .attachPartialSheetToRoot()
        .toast(isPresenting: $toastManager.errorToast) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: toastManager.errorMessage, subTitle: toastManager.errorSubMessage)
        }
        .toast(isPresenting: $toastManager.toast) {
            AlertToast(displayMode: .hud, type: .regular, title: "\(toastManager.toastMessage)")
        }
    }
}
