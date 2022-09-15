import Foundation
import SwiftUI
import Alamofire

class ReferralsViewModel: ObservableObject {
    @Published var numberReferred : Int = 0
    
    func getNumReferred(){
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/referrals/", method: .get, successType: ReferralResponse.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.numberReferred = successResponse.numberReferred
            }
        }
    }
    
    func getReferralsText() -> String {
        if self.numberReferred == 0 {
            return "absolutely NO referrals."
        }
        else {
            return "\(self.numberReferred) referrals. Sweet moolah."
        }
    }
}
