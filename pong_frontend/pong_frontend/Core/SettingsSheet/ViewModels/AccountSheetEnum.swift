//
//  AccountSheetEnum.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

enum AccountSheetEnum: Int, CaseIterable {
    case changePhone
    case changeEmail
    case deleteAccount
    
    var title: String {
        switch self {
        case .deleteAccount: return "Delete Account"
        case .changePhone: return "Change Phone Number"
        case .changeEmail: return "Change Email"
        }
    }
    
    var imageName: String {
        switch self {
        case .deleteAccount: return "trash"
        case .changePhone: return "phone"
        case .changeEmail: return "envelope"
        }
    }
}
