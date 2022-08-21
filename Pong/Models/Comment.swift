//
//  Comment.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Comment: Hashable, Identifiable, Codable {
    var id: String
    var post: String
    var comment: String
    var createdAt: String
    var updatedAt: String
    var score: Int
    var timeSincePosted: String
    var parent: String?
    var children: [Comment]
    var numberOnPost: Int
    var userOwned: Bool
    var voteStatus: Int
    var numUpvotes: Int
    var numDownvotes: Int
    var numberReplyingTo: Int?
    var image: String?
}
