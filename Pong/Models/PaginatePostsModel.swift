//
//  PaginatePostsModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/20/22.
//

import Foundation

struct PaginatePostsModel {
    struct Response : Codable {
        let count : Int
        let next : String?
        let previous: String?
        let results: [Post]
    }
}
