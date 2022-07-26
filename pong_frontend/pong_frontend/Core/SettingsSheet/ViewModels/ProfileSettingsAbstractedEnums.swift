//
//  ProfileSettingsAbstractedEnums.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/26/22.
//

import Foundation


// bruh even with the switch case the return types cannot be implicit so fucking annoying
enum ProfileSettingsAbstractedEnums: Int, CaseIterable {
    case settingsSheet
    case accountsSheet
    case notificationsSheet
    case preferencesSheet
}
