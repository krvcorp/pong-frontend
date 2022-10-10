import SwiftUI
import AlertToast

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : String?
    @Published var post : Post = defaultPost
    
    func readPost(url : String) {
        NetworkManager.networkManager.request(route: "posts/\(url)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: \(successResponse)")
                    self.post = successResponse
                }
            }
            
            if errorResponse != nil {
                print("DEBUG: error")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @ObservedObject var appState = AppState.shared
    @ObservedObject private var authManager = AuthManager.authManager
    @State var showMenu = false
    
    init() {
        AuthManager.authManager.loadCurrentState()
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @State var navigate = false
    
    var pushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.pageToNavigationTo != nil
        } set: { (newValue) in
            if !newValue {
                appState.pageToNavigationTo = nil
            }
        }
    }
    
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
                if (!AuthManager.authManager.isSignedIn) {
                    EmailVerificationView()
                        .toast(isPresenting: $authManager.signedOutAlert) {
                            AlertToast(displayMode: .hud, type: .regular,  title: "Signed out! We hope to see you soon")
                        }
                } else if (!AuthManager.authManager.onboarded) {
                    OnboardingView()
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
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top, .bottom])
            .overlay(NavigationLink(destination: PostView(post: $appState.post), isActive: pushNavigationBinding) {
                EmptyView()
            })
        }
        .environmentObject(MainTabViewModel(initialIndex: 1, customItemIndex: 3))
        .environmentObject(dataManager)
        .accentColor(Color(UIColor.label))
    }
}
