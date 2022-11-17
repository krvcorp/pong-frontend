import Foundation
import GoogleSignIn
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var firstCall : Bool = true
    @Published var welcomed: Bool = false
    @Published var referred: Bool = false
    
    @Published var wrongCodeError: Bool = false
    @Published var errorMessage : String = ""
    
    // MARK: SetReferrer
    /// Redeems a referral code
    func setReferrer(referralCode: String) {
        let parameters = SetReferrer.Request(referralCode: referralCode)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/refer/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        self.referred = true
                        DAKeychain.shared["referred"] = "true"
                        ToastManager.shared.toastDetected(message: "Success")
                    }
                }
            }
            
            if let errorResponse = errorResponse {
                DispatchQueue.main.async {
                    withAnimation {
                        self.wrongCodeError = true
                        self.errorMessage = errorResponse.error
                    }
                }
            }
        }
    }
    
    // MARK: Onboard
    /// Onboards the user
    func onboard() {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/onboard/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                withAnimation {
                    AuthManager.authManager.onboarded = true
                    DAKeychain.shared["onboarded"] = "true"
                }
            }
        }
    }
}
