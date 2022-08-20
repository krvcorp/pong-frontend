//
//  PollVoteModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/18/22.
//

import Foundation

struct PollVoteModel {
    struct Request: Encodable {
        let pollOptionId: String
    }
    
    struct Response: Decodable {
        let voteStatus: Int?
        let error: String?
    }
}

