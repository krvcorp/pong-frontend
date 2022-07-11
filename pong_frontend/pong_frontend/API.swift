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

struct PostRequestBody: Codable {
    let title: String
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
