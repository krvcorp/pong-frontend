//
//  PreferenceSettingsEnum.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

enum PreferenceSettingsEnum: Int, CaseIterable {
    case lightOrDarkAuto
    case darkMode
    
    var title: String {
        switch self {
        case .lightOrDarkAuto: return "Automatic (follow iOS Setting)"
        case .darkMode: return "Dark Mode"
        }
    }
    
    var imageName: String {
        switch self {
        case .lightOrDarkAuto: return "gear"
        case .darkMode: return "moon"
        }
    }
}
