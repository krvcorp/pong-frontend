//
//  Comment.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Comment: Hashable, Identifiable, Codable {
    let id: String
    let post: String
    let user: String
    let comment: String
    let createdAt: String
    let updatedAt: String
    let score: Int
    let timeSincePosted: String
    let parent: String?
    let children: [Comment]
    let numberOnPost: Int
}
