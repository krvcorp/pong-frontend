//
//  CommentReplyModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/9/22.
//

import Foundation

struct CommentReplyModel {
    struct Request: Encodable {
        let postId: String
        let replyingId: String
        let comment: String
    }
    
    struct Response: Decodable {
        let comment: Comment
    }
}
