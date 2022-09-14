import Foundation
import GoogleSignIn
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var firstCall : Bool = true
    @Published var welcomed: Bool = false
    @Published var onBoarded: Bool = false
    
    func setReferrer(referralCode: String) {
        let parameters = SetReferrer.Request(referralCode: referralCode)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/refer/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        self.onBoarded = true
                    }
                }
            }
            
            if errorResponse != nil {

            }
        }
    }
    
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