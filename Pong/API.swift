//
//  API.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

enum AuthenticationError: Error {
    case decodeError
    case noData
    case custom(errorMessage: String)
}

class API: ObservableObject {
    var root: String = "http://localhost:8005/api/"
    var rootAuth: String = "http://localhost:8005/auth/"
}
