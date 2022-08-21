import Foundation
import SwiftUI
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    
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
