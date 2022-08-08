//
//  SettingsViewModel.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

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
    
    func logout() {
        DispatchQueue.main.async {
            print("DEBUG: logout")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//            self.initialOnboard = true
            GIDSignIn.sharedInstance.disconnect()
            DAKeychain.shared["userId"] = nil
            DAKeychain.shared["token"] = nil
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
