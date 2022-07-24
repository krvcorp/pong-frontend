//
//  TokenSignInRequestBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/23/22.
//

import Foundation

struct TokenSignRequestBody: Encodable {
    let idToken : String
    let phone : String
}
