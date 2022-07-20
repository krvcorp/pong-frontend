//
//  Comment.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Comment: Identifiable, Codable {
    var id: String
    var post: String
    var user: String
    var comment: String
    var createdAt: String
    var updatedAt: String
    var score: Int
    var timeSincePosted: String
}
