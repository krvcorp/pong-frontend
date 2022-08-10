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
    // MARK: Local
    var root: String = "http://localhost:8005/api/"
    var rootAuth: String = "http://localhost:8005/auth/"
    
    // MARK: ngrok
//    var root: String = "https://b6d9-2600-4040-49e9-4700-3c24-5cf8-d8e0-5a0b.ngrok.io/api/"
//    var rootAuth: String = "https://b6d9-2600-4040-49e9-4700-3c24-5cf8-d8e0-5a0b.ngrok.io/auth/"
    
    // MARK: Online
//    var root: String = "https://raunakdaga-pong.herokuapp.com/api/"
//    var rootAuth: String = "https://raunakdaga-pong.herokuapp.com/auth/"
}
