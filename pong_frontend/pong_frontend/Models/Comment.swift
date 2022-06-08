//
//  Comment.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Comment: Identifiable, Codable {
    var id: String
    var user: String
    var post: String
    var comment: String
    var createdAt: Date
    var updatedAt: Date
}
