//
//  PaginateProfileCommentsModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/28/22.
//

import Foundation

struct PaginateProfileCommentsModel {
    struct Response : Codable {
        let count : Int
        let next : String?
        let previous: String?
        let results: [ProfileComment]
    }
}
