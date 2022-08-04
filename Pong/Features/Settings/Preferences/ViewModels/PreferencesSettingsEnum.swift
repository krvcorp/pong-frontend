//
//  PreferencesSettingsEnum.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

enum PreferencesSettingsEnum: Int, CaseIterable {
    case displayModeSetting
    
    var title: String {
        switch self {
        case .displayModeSetting: return "Display Mode Setting"
        }
    }
    
    var imageName: String {
        switch self {
        case .displayModeSetting: return "gear"
        }
    }
}
