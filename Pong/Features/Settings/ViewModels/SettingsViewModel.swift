import Foundation
import SwiftUI
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    @Published var numberReferred : Int = 0
    
    @Published var enableStagingServer = false {
        didSet {
            NetworkManager.networkManager.baseURL = enableStagingServer ? "https://staging.posh.vip" : "https://posh.vip"
        }
    }
    
    func deleteAccount() {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/", method: .delete) { successResponse, errorResponse in
            DispatchQueue.main.async {
                AuthManager.authManager.signout()
            }
        }
    }
    
    func getNumReferred(){
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/referrals/", method: .get, successType: ReferralResponse.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.numberReferred = successResponse.numberReferred
            }
        }
    }
    
    func changeNotifications(setTo: Bool) {
        if (setTo) {
            NetworkManager.networkManager.emptyRequest(route: "notifications/enable/", method: .post) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    debugPrint(successResponse)
                }
            }
        }
        else {
            NetworkManager.networkManager.emptyRequest(route: "notifications/disable", method: .post) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    debugPrint(successResponse)
                }
            }
        }
    }
    
    func updateNickname(nickname: String) {
        let parameters = Nickname.self(nickname: nickname)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/nickname/", method: .post, body: parameters) { successResponse, errorResponse in
            if let successResponse = successResponse {
                debugPrint(successResponse)
            }
        }
    }
    
}



enum DisplayMode: Int {
    case system, dark, light
    
    func setAppDisplayMode() {
        var userInterfaceStyle: UIUserInterfaceStyle
        switch self {
            case .system: userInterfaceStyle = .unspecified
            case .dark: userInterfaceStyle = .dark
            case .light: userInterfaceStyle = .light
        }
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}
