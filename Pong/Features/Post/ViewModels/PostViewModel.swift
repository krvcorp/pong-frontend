//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    @Published var comments : [Comment] = []
    @Published var showDeleteConfirmationView : Bool = false
    
    func postVote(direction: Int, completion: @escaping (Result<PostVoteModel.Response, AuthenticationError>) -> Void) {
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
        
        let body = PostVoteModel.Request(postId: post.id, vote: voteToSend)
        
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
            guard let postVoteResponse = try? decoder.decode(PostVoteModel.Response.self, from: data!) else {
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
            completion(.failure(.custom(errorMessage: "Nothing")))
            
        }.resume()
    }
    
    func getComments() -> Void {
        print("DEBUG: postVM getComments")

        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        guard let url = URL(string: "\(API().root)comment/?post_id=\(post.id)") else {
            print("DEBUG: URL is not correct")
            return
        }
        
        // URL handler
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // Task handler. [weak self] prevents memory leaks
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("DEBUG: error")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let getCommentsResponse = try? decoder.decode([Comment].self, from: data) else {
                print("DEBUG: decode error")
                return
            }
            
            DispatchQueue.main.async {
                self.comments = getCommentsResponse
            }
        }.resume()
    }
    
    
    func createComment(comment: String, completion: @escaping (Result<Comment, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
            
        // comment API
        guard let url = URL(string: "\(API().root)comment/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = CreateCommentRequestBody(post_id: post.id, comment: comment)
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
            DispatchQueue.main.async {
                self.comments.append(commentResponse)
                completion(.success(commentResponse))
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
                completion(.failure(.decodeError))
                return
            }
            debugPrint(commentResponse)
            completion(.success(commentResponse.comment))
            
        }.resume()
    }
    
    // this logic should probably go into feedviewmodel where tapping on a post calls an API to get updated post information regarding a post
    func readPost(completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        print("DEBUG: postVM readPost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
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
    
    func deletePost() {
        print("DEBUG: postVM.deletePost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.showDeleteConfirmationView = false
            }
        }.resume()
    }}
