//
//  AccountsSheetEnum.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

enum AccountsSheetEnum: Int, CaseIterable {
    case deleteAccount
    
    var title: String {
        switch self {
        case .deleteAccount: return "Delete Account"
        }
    }
    
    var imageName: String {
        switch self {
        case .deleteAccount: return "trash"
        }
    }
}
