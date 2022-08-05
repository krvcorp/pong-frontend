//
//  PreferencesSettingsViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/26/22.
//

import Foundation
import SwiftUI

class PreferencesSettingsViewModel: ObservableObject {
    @Published var lightOrDarkAuto = false
    @Published var darkMode = false
    
    enum DisplayMode: Int {
        case system, dark, light
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .dark: return ColorScheme.dark
            case .light: return ColorScheme.light
            }
        }
        
        func setAppDisplayMode() {
            var userInterfaceStyle: UIUserInterfaceStyle
            switch self {
            case .system: userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
            case .dark: userInterfaceStyle = .dark
            case .light: userInterfaceStyle = .light
            }
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            scene?.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
        }
    }
    
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    
    
}
