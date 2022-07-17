//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func postVote(id: String, direction: Int, currentDirection: Int, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        print("DEBUG: postVote \(direction) \(id) \(token)")
            
        // change URL to real login
        guard let url = URL(string: "\(API().root)postvote/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = PostVoteRequestBody(post_id: id, user: "9fcafc5b-1519-409c-982c-05189a7ea98b", vote: direction)
        
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
            
            // response stuff if it exists
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let loginResponse = try? decoder.decode(Post.self, from: data) else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
//
//            completion(.success(loginResponse.title))
            
        }.resume()
    }
    
    func createComment(postid: String, comment: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        
        print("DEBUG: createComment \(postid) \(comment) \(token)")
            
        // comment API
        guard let url = URL(string: "\(API().root)comment/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = CreateCommentRequestBody(post: postid, user: "9fcafc5b-1519-409c-982c-05189a7ea98b", comment: comment)
        
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
            
            // response stuff if it exists
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let loginResponse = try? decoder.decode(Post.self, from: data) else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
//
//            completion(.success(loginResponse.title))
            
        }.resume()
    }
    

}
