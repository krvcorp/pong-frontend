//
//  PostVoteModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/8/22.
//

import Foundation

struct PostVoteModel {
    
    struct Request: Encodable {
        let postId: String
        let vote: Int
    }
    
    struct Response: Decodable {
        let voteStatus: Int?
        let error: String?
    }
}
