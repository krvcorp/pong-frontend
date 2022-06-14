//
//  SettingsViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/12/22.
//

import Foundation

enum SettingsViewModel: Int, CaseIterable {
    case notifications
    case legal
    case account
    case logout
    
    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .legal: return "Legal"
        case .account: return "Account"
        case .logout: return "Logout"
        }
    }
    
    var imageName: String {
        switch self {
        case .notifications: return "bell"
        case .legal: return "newspaper.fill"
        case .account: return "person.crop.circle"
        case .logout: return "arrow.right.square"
        }
    }
}
