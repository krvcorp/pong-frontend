//
//  Comment.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Comment: Identifiable, Codable {
    var id: Int
    var post: Int
    var user: Int
    var comment: String
    var created_at: String
    var updated_at: String
    var total_score: Int
}

//{
//    "id": 11,
//    "post": 7,
//    "user": 2,
//    "comment": "Hi",
//    "created_at": "2022-06-08T22:27:34.366174Z",
//    "updated_at": "2022-06-08T22:27:34.366203Z",
//    "total_score": 0
//}
