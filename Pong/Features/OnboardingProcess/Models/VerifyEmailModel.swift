//
//  VerifyEmailModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/8/22.
//

import Foundation

struct VerifyEmailModel {
    struct Request : Encodable {
        let idToken : String
        let loginType : String
    }
    
    struct Response : Codable {
        let token : String?
        let userId : String?
        let isAdmin: Bool?
        let dateJoined: String?
        let referralCode: String?
        let onboarded: Bool?
    }
}
