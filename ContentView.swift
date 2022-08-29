import SwiftUI

struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    @State var showMenu = false
    
    init() {
        AuthManager.authManager.loadCurrentState()
        UITableView.appearance().showsVerticalScrollIndicator = false
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
        
        if (!AuthManager.authManager.isSignedIn) {
            EmailVerificationView()
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
                    }
                }
                .offset(x: self.showMenu ? 0 : -UIScreen.screenWidth/1.5)
            }
            .gesture(drag)
        }
    }
}
