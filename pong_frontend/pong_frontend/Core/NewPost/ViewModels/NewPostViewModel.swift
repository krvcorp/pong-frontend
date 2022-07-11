//
//  NewPostViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/2/22.
//

import Foundation

class NewPostViewModel: ObservableObject {
//    @Published var post: Post = default_post
    
    // LIST OF OBJECTS
    func newPost(title: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        let defaults = UserDefaults.standard
        
        guard let token = defaults.string(forKey: "jsonwebtoken") else {
                return
            }
        
        // change URL to real login
        guard let url = URL(string: "http://127.0.0.1:8005/api/post/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = PostRequestBody(title: title)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let loginResponse = try? decoder.decode(Post.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(loginResponse.title))
            
        }.resume()
    }
}
