//
//  User.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var name: String
    var timeout: Date
    var phone: String
    var has_been_verified: Bool
    
    var is_active: Bool
    var is_staff: Bool
    var is_superuser: Bool
    var last_login: Date
    var date_joined: Date
}

