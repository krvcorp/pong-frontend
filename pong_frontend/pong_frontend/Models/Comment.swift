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
    var post: Int
    var comment: String
    var created_at: String
    var updated_at: String
    var score: Int
}
