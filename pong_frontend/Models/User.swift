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
    var hasBeenVerified: Bool
    var banned: Bool
    var schoolAttending: String
    
    var chatNotifications: Bool
    var trendingPostNotifications: Bool
    var activityNotifications: Bool
    
    var isActive: Bool
    var isStaff: Bool
    var isSuperuser: Bool
    var lastLogin: Date
    var dateJoined: Date
}

