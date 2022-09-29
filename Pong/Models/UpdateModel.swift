//
//  UpdateModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/27/22.
//

import Foundation

struct UpdateModel {
    struct Request : Encodable {
        let version : String
        let build : String
    }

    struct Response : Codable {
        let updateRequired : Bool
    }
}
