//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func postVote(id: String, direction: Int, currentDirection: Int, completion: @escaping (Result<Int, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        print("DEBUG: postVote \(direction) \(id) \(token)")
            
        // change URL to real login
        guard let url = URL(string: "\(API().root)postvote/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = PostVoteRequestBody(postId: id, vote: direction)
        
        var request = URLRequest(url: url)
        if (currentDirection == 1 || currentDirection == -1) && direction != currentDirection {
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
            
            guard let _ = data, error == nil else {
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
    
    func createComment(postid: String, comment: String, completion: @escaping (Result<Comment, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
            
        // comment API
        guard let url = URL(string: "\(API().root)comment/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = CreateCommentRequestBody(post_id: postid, comment: comment)
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
                completion(.failure(.custom(errorMessage: "Decode failed")))
                return
            }
            
            completion(.success(commentResponse))
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
    // this logic should probably go into feedviewmodel where tapping on a post calls an API to get updated post information regarding a post
    func readPost(postId: String, completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        print("DEBUG: postVM readPost \(postId)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(postId)/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("DEBUG: postVM readPost data \(data!)")
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let postResponse = try? decoder.decode(Post.self, from: data) else {
                completion(.failure(.custom(errorMessage: "Decode failure")))
                return
            }
            completion(.success(postResponse))
            
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
