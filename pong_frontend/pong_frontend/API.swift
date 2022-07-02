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

struct LoginRequestBody: Codable {
    let email_or_username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String?
    let message: String?
    let success: Bool?
}

class API: ObservableObject {
    @Published var posts: [Post] = []
    
    func getPosts() {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/getPosts/") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
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
    
    func login(email_or_username: String, password: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
            
        // change URL to real login
        guard let url = URL(string: "http://127.0.0.1:8005/api/login/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = LoginRequestBody(email_or_username: email_or_username, password: password)
        
        print(body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            try! JSONDecoder().decode(LoginResponse.self, from: data)
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            guard let token = loginResponse.token else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(token))
            
        }.resume()
            
    }
    
}
