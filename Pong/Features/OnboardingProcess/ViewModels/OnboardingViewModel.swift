import Foundation
import GoogleSignIn

class OnboardingViewModel: ObservableObject {
    @Published var firstCall : Bool = true
    @Published var welcomed: Bool = false
    
    @Published var errorReferralCode : Bool = false
    @Published var successReferralCode : Bool = true
    
    func setReferrer(referralCode: String, completion: @escaping (Bool) -> Void) {
        let parameters = SetReferrer.Request(referralCode: referralCode)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/refer/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.successReferralCode.toggle()
                }
                completion(true)
            }
            
            if errorResponse != nil {
                self.errorReferralCode.toggle()
            }
        }
    }
    
    func onboard(completion: @escaping (Bool) -> Void) {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/onboard/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                completion(true)
            }
        }
    }
}
