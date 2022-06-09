//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Post: Codable, Hashable, Identifiable {
    var id: Int
    var user: Int
    var title: String
    var created_at: String
    var updated_at: String
}

//{
//    "id": 7,
//    "user": 2,
//    "title": "This is a test post.",
//    "created_at": "2022-06-04T17:26:35.286032Z",
//    "updated_at": "2022-06-04T17:26:35.286043Z"
//}
