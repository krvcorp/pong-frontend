//
//  OTPVerifyResponseBody.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

// token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
struct OTPVerifyResponseBody: Decodable {
    let token: String?
    let emailUnverified: Bool?
    let codeExpire: Bool?
    let codeIncorrect: Bool?
    let userId: String?
}
