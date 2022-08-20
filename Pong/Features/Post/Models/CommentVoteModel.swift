//
//  CommentVoteModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/8/22.
//

import Foundation

struct CommentVoteModel {
    
    struct Request: Encodable {
        let vote: Int
    }
    
    struct Response: Decodable {
        let voteStatus: Int
    }
}
