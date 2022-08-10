import SwiftUI

struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    
    init() {
        AuthManager.authManager.loadCurrentState()
    }
    
    var body: some View {
        if (!AuthManager.authManager.isSignedIn) {
            OnboardView()
        } else if (AuthManager.authManager.isSignedIn) && (AuthManager.authManager.initialOnboard){
            WelcomeView()
        } else {
            MainInterfaceView
        }
    }
}

extension ContentView {
    var MainInterfaceView: some View {
        ZStack(alignment: .topTrailing){
            MainTabView()
        }
    }
}
