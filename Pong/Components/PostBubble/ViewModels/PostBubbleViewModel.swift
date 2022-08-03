//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    init(post: Post) {
        self.post = post
    }
    
    func postVote(direction: Int, completion: @escaping (Result<PostVoteResponseBody, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        print("DEBUG: postVote \(direction)")
            
        // change URL to real login
        guard let url = URL(string: "\(API().root)postvote/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        var voteToSend = 0
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let body = PostVoteRequestBody(postId: post.id, vote: voteToSend)
        
        print("DEBUG: \(body)")
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // THIS IS REAL CODE UNCOMMENT WHEN JSON RESPONSE IS FIXED
            guard let postVoteResponse = try? decoder.decode(PostVoteResponseBody.self, from: data!) else {
                completion(.failure(.decodeError))
                return
            }

            if let responseDataContent = postVoteResponse.voteStatus {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
                completion(.success(postVoteResponse))
                return
            }

            if let responseDataContent = postVoteResponse.error {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.error is \(responseDataContent)")
                completion(.success(postVoteResponse))
                return
            }
  
            // THIS IS DUMMY COMMENT WHEN JSON IS FIXED
//            print("DEBUG: DECODE FAILED DUMMY RETURN")
            
//            completion(.success(PostVoteResponseBody(voteStatus: voteToSend, error: nil)))
            completion(.failure(.custom(errorMessage: "Nothing")))
            
        }.resume()
    }
    
    func reportPost(postId: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)postreport/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = CreatePostReportRequestBody(postId: postId)
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
            guard let commentResponse = try? decoder.decode(Comment.self, from: data) else {
                completion(.failure(.decodeError))
                return
            }
            debugPrint(commentResponse)
            completion(.success(commentResponse.comment))
            
        }.resume()
    }
    

}
