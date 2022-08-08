import SwiftUI

struct ContentView: View {
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {
        if DAKeychain.shared["token"] != nil && !loginVM.initialOnboard {
            MainInterfaceView
        } else if DAKeychain.shared["token"] != nil {
            WelcomeView(loginVM: loginVM)
        } else {
            OnboardView(loginVM: loginVM)
        }
    }
}

extension ContentView {
    var MainInterfaceView: some View {
        ZStack(alignment: .topTrailing){
            MainTabView()
                .environmentObject(loginVM)
        }
    }
}
