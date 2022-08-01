//
//  User.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var posts: [Post]
    var comments: [Comment]
    var inTimeout: Bool
    var phone: String
    var commentScore: Int
    var postScore: Int
    var totalScore: Int
    var upvotedPosts: [Post]
    var savedPosts: [Post]
}

