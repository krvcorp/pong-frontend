//
//  CommentCreateModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/12/22.
//

import Foundation

struct CommentCreateModel {
    struct Request: Encodable {
        let comment: String
    }
}
