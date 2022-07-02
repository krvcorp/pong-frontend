//
//  User.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var zipcode: String
    var country: String
    var createdAt: Date
    var updatedAt: Date
    var password: String
    var timeout: Date
}

