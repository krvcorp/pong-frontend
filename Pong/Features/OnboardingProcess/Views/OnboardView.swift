import SwiftUI

struct OnboardView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        // MARK: Old onboarding with phone login
        EmailVerificationView()
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
