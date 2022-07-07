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
}

//{
//    "id": 7,
//    "user": 2,
//    "title": "This is a test post.",
//    "created_at": "2022-06-04T17:26:35.286032Z",
//    "updated_at": "2022-06-04T17:26:35.286043Z",
//    "image": null,
//    "num_comments": 6,
//    "comments": [
