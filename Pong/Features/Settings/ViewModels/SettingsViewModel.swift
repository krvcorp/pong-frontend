//
//  SettingsViewModel.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var enableStagingServer = false {
        didSet {
            NetworkManager.networkManager.baseURL = enableStagingServer ? "https://staging.posh.vip" : "https://posh.vip"
        }
    }
    
    func logout() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
