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
}

//{
//    "id": 5,
//    "post": 7,
//    "user": 2,
//    "comment": "Hey",
//    "created_at": "2022-06-04T18:32:55.105139Z",
//    "updated_at": "2022-06-04T18:32:55.105175Z"
//}
