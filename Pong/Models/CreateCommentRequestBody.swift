//
//  CreateCommentRequestBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/16/22.
//

import Foundation

struct CreateCommentRequestBody: Encodable {
    let postId: String
    let comment: String
}
