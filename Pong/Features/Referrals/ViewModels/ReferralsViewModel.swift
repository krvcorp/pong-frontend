import Foundation
import SwiftUI
import Alamofire

class ReferralsViewModel: ObservableObject {
    @Published var referred = DAKeychain.shared["referred"] != nil ? true : false
    
    func getNumReferred(){
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/referrals/", method: .get, successType: ReferralResponse.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DataManager.shared.numberReferred = successResponse.numberReferred
            }
        }
    }
    
    func getReferralsText() -> String {
        if DataManager.shared.numberReferred == 0 {
            return "Oof, kind of embarassing."
        }
        else {
            return "Get that bag."
        }
    }
    
    func setReferrer(referralCode: String, dataManager : DataManager) {
        let parameters = SetReferrer.Request(referralCode: referralCode)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/refer/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        DAKeychain.shared["referred"] = "true"
                        self.referred = true
                    }
                }
            }
            
            if let errorResponse = errorResponse {
                DispatchQueue.main.async {
                    ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: errorResponse.error)
                }
            }
        }
    }
}
