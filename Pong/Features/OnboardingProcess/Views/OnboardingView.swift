import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    @StateObject var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        if (!onboardingVM.welcomed){
            WelcomeView()
                .environmentObject(onboardingVM)
        } else {
            ReferralOnboardingView()
                .environmentObject(onboardingVM)
        }
    }
}

