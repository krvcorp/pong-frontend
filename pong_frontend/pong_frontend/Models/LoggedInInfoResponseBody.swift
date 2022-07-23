//
//  LoggedInInfoResponseBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

// response should always be decodable
//
struct LoggedInUserInfoResponseBody: Decodable {
    let id: String
    let email: String?
    let posts: [Post]
    let comments: [Comment]
    let inTimeout: Bool
    let phone: String
    let totalKarma: Int
    let commentKarma: Int
    let postKarma: Int
}
