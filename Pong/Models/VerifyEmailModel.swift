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
    }
    
    struct Response : Codable {
        let token : String?
        let user : User?
    }
    
    struct User : Codable {
        let id : String?
    }
}
