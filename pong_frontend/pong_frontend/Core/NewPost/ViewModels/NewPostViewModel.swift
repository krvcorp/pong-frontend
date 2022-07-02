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
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            try! JSONDecoder().decode(Post.self, from: data)
            
            guard let loginResponse = try? JSONDecoder().decode(Post.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            print("DEBUG: \(loginResponse)")
            
//            DispatchQueue.main.async {
//                self.post = loginResponse
//            }
            
            completion(.success(loginResponse.title))
            
        }.resume()
    }
}
