//
//  PaginateCommentsModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import Foundation

struct PaginateCommentsModel {
    struct Response : Codable {
        let count : Int
        let next : String?
        let previous: String?
        let results: [Comment]
    }
}
