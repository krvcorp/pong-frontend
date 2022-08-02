//
//  NewPostViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/2/22.
//

import Foundation

class NewPostViewModel: ObservableObject {
    @Published var error = false

    func newPost(title: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        // change URL to real login
        guard let url = URL(string: "\(API().root)post/") else {
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
            guard let createPostResponse = try? decoder.decode(Post.self, from: data) else {
                guard let createPostResponse = try? decoder.decode(ErrorResponseBody.self, from: data) else {
                    completion(.failure(.decodeError))
                    return
                }

                DispatchQueue.main.async {
                    self.error = true
                }
                completion(.success(createPostResponse.error))
                return
            }
            
            completion(.success(createPostResponse.title))
            
        }.resume()
    }
}
