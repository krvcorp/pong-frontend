//
//  OTPStartResponseBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

struct OTPStartResponseBody: Decodable {
    let newUser: Bool?
    let phone: String?
}
