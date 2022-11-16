import Foundation
import SwiftUI
import GoogleSignIn

enum SettingsActiveAlert {
    case unblockAll, signOut, deleteAccount
}

struct Settings {
    struct Request: Encodable { let enabled: Bool }
    struct Success: Decodable {}
}

class SettingsViewModel: ObservableObject {
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    @Published var numberReferred : Int = 0
    @Published var activeAlert : Bool = false
    @Published var activeAlertType : SettingsActiveAlert = .unblockAll
    
    static let shared = SettingsViewModel()
    
    func deleteAccount() {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/", method: .delete) { successResponse, errorResponse in
            DispatchQueue.main.async {
                AuthManager.authManager.signout(force: true)
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
        NetworkManager.networkManager.request(route: "notifications/settingshandler/", method: .post, body: Settings.Request(enabled: setTo), successType: Settings.Success.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                debugPrint(successResponse)
            }
        }
    }
    
    func unblockAll() {
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/unblockall/", method: .delete) { successResponse, errorResponse in
            if let successResponse = successResponse {
                debugPrint(successResponse)
            }
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func openNotifications() {
        // Create the URL that deep links to your app's custom settings.
        if let url = URL(string: UIApplication.openSettingsURLString) {
            // Ask the system to open that URL.
            UIApplication.shared.open(url)
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
