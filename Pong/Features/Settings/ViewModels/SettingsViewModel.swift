//
//  SettingsViewModel.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    
    @Published var enableStagingServer = false {
        didSet {
            NetworkManager.networkManager.baseURL = enableStagingServer ? "https://staging.posh.vip" : "https://posh.vip"
        }
    }
    
    func logout() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
