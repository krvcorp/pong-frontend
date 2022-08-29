//
//  CommentListModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/29/22.
//

import Foundation

struct CommentListModel {
    struct Response : Codable {
        let count : Int
        let next : String?
        let previous: String?
        let results: [Comment]
    }
}
