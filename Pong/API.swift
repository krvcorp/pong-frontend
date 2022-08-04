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
    var root: String = "https://raunakdaga-pong.herokuapp.com/api/"
    var rootAuth: String = "https://raunakdaga-pong.herokuapp.com/auth/"
}
