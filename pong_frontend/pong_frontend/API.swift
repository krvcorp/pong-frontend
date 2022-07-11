//
//  API.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

struct LoginResponse: Codable {
    let token: String?
    let message: String?
    let success: Bool?
}

struct PostRequestBody: Codable {
    let title: String
}

struct OTPStartRequestBody: Codable {
    let phone: String
}

struct OTPStartResponseBody: Codable {
    let newUser: Bool?
    let phone: String?
}

struct OTPVerifyRequestBody: Codable {
    let phone: String
    let code: String
}

// token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
struct OTPVerifyResponseBody: Codable {
    let token: String?
    let emailUnverified: Bool?
    let codeExpire: Bool?
    let codeIncorrect: Bool?
}

struct VerifyEmailRequestBody: Codable {
    let phone: String
    let email: String
}

struct VerifyEmailResponseBody: Codable {
    let token: String?
}

struct LoggedInUserInfoResponseBody: Codable {
    let id: String
    let email: String
    let posts: [Post]
    let comments: [Comment]
    let inTimeout: Bool
    let phone: String
    let totalKarma: Int
    let commentKarma: Int
    let postKarma: Int
    
}

class API: ObservableObject {
    var root: String = "http://localhost:8005/api/"
    @Published var posts: [Post] = []
    
    func getPosts() {
        print("DEBUG: API getPosts")
        
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        // url handler
        guard let url = URL(string: "\(root)" + "post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let posts = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self?.posts = posts
                }
            } catch {
                print("DEBUG: \(error)")
            }
        }
        // activates api call
        task.resume()
    }
}
