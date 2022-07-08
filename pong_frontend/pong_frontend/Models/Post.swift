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
    var created_at: String
    var updated_at: String
    
    var num_comments: Int
    var comments: [Comment]
    var score: Int
    var time_since_posted: String
}

