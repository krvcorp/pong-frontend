//
//  PostVoteRequestBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/16/22.
//

import Foundation

struct PostVoteRequestBody: Encodable {
    let post: String
    let user: String
    let vote: String
}
