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

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class API: ObservableObject {
    var root: String = "http://localhost:8005/api/"
    var rootAuth: String = "http://localhost:8005/auth/"
    @Published var posts: [Post] = []
    
    func getPosts() {
        
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        guard let url = URL(string: "\(root)" + "post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let posts = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self?.posts = posts
                }
            } catch { }
        }
        task.resume()
    }
}
