//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    
    func postVote(id: String, direction: Int, currentDirection: Int, completion: @escaping (Result<PostVoteResponseBody, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        print("DEBUG: postVote \(direction)")
            
        // change URL to real login
        guard let url = URL(string: "\(API().root)postvote/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        var voteToSend = 0
        
        if direction == currentDirection {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let body = PostVoteRequestBody(postId: id, vote: voteToSend)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // THIS IS REAL CODE UNCOMMENT WHEN JSON RESPONSE IS FIXED
//            guard let postVoteResponse = try? decoder.decode(PostVoteResponseBody.self, from: data) else {
//                completion(.failure(.decodeError))
//                return
//            }
//
//            if let responseDataContent = postVoteResponse.voteStatus {
//                print("DEBUG: postBubbleVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
//                completion(.success(postVoteResponse))
//                return
//            }
//
//            if let responseDataContent = postVoteResponse.error {
//                print("DEBUG: postBubbleVM.postVote postVoteResponse.error is \(responseDataContent)")
//                completion(.success(postVoteResponse))
//                return
//            }
  
            // THIS IS DUMMY COMMENT WHEN JSON IS FIXED
            print("DEBUG: DECODE FAILED DUMMY RETURN")
            
            completion(.success(PostVoteResponseBody(voteStatus: voteToSend, error: nil)))
//            completion(.failure(.custom(errorMessage: "Nothing")))
            
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
    
    func deletePost(post: Post, feedVM: FeedViewModel, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        print("DEBUG: PostBubbleVM deletePost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            DispatchQueue.main.async {
                // clear locally the deleted post
                if let index = feedVM.hotPosts.firstIndex(of: post) {
                    feedVM.hotPosts.remove(at: index)
                }
                if let index = feedVM.recentPosts.firstIndex(of: post) {
                    feedVM.recentPosts.remove(at: index)
                }
                if let index = feedVM.topPosts.firstIndex(of: post) {
                    feedVM.topPosts.remove(at: index)
                }
            }
        }.resume()
    }
}
