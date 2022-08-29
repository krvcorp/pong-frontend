import SwiftUI

struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    
    init() {
        AuthManager.authManager.loadCurrentState()
    }
    
    var body: some View {
        if (!AuthManager.authManager.isSignedIn) {
            EmailVerificationView()
        } else if (!AuthManager.authManager.onboarded) {
            OnboardingView()
        } else {
            ZStack(alignment: .topTrailing) {
                MainTabView()
            }
        }
    }
}
