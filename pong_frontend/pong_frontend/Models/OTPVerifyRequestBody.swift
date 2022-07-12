//
//  OTPVerifyRequestBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

struct OTPVerifyRequestBody: Encodable {
    let phone: String
    let code: String
}
