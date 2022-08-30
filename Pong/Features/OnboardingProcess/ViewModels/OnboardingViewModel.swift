import Foundation
import GoogleSignIn

class OnboardingViewModel: ObservableObject {
    @Published var firstCall : Bool = true
    @Published var welcomed: Bool = false
    
    func setReferrer(referralCode: String) {
        let parameters = SetReferrer.Request(referralCode: referralCode)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/refer/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    AuthManager.authManager.onboarded = true
                    DAKeychain.shared["onboarded"] = "true"
                }
            }
            
            if errorResponse != nil {

            }
        }
    }
    
    func onboard() {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/onboard/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                AuthManager.authManager.onboarded = true
                DAKeychain.shared["onboarded"] = "true"
            }
        }
    }
}
