//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var user: String
    var title: String
    var image: String?
    var createdAt: String
    var updatedAt: String
    var saved: Bool
    var flagged: Bool
    var blocked: Bool
    
    var numComments: Int
    var comments: [Comment]
    var score: Int
    var timeSincePosted: String
    var voteStatus: Int
}

extension Post: Equatable {}
func ==(lhs: Post, rhs: Post) -> Bool {
    let areEqual = lhs.id == rhs.id
    return areEqual
}

