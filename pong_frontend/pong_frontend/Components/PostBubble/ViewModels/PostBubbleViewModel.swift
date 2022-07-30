//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    
    func postVote(id: String, direction: Int, currentDirection: Int, completion: @escaping (Result<Int, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        print("DEBUG: postVote \(direction) \(id) \(token)")
            
        // change URL to real login
        guard let url = URL(string: "\(API().root)postvote/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = PostVoteRequestBody(post_id: id, user: "9fcafc5b-1519-409c-982c-05189a7ea98b", vote: direction)
        
        var request = URLRequest(url: url)
        if currentDirection != 0 {
            request.httpMethod = "PATCH"
        } else {
            request.httpMethod = "POST"
        }

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
            
            // upvote on upvote or downvote on downvote
            if currentDirection == direction {
                completion(.success(0))
            } else if direction == 1 {
                completion(.success(1))
            } else if direction == -1 {
                completion(.success(-1))
            }
            
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
                completion(.failure(.invalidCredentials))
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
            guard let data = data, error == nil else {
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
