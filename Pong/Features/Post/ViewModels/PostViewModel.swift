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
    @Published var replyToComment : Comment = defaultComment
    
    func postVote(direction: Int) -> Void {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)postvote/") else { return }
        
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
                print("DEBUG: postBubbleVM.postVote no data")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            guard let postVoteResponse = try? decoder.decode(PostVoteModel.Response.self, from: data!) else {
                print("DEBUG: postBubble.postVote Decode Error")
                return
            }

            if let responseDataContent = postVoteResponse.voteStatus {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
                DispatchQueue.main.async {
                    self.post.voteStatus = responseDataContent
                }
                return
            }

            if let responseDataContent = postVoteResponse.error {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.error is \(responseDataContent)")
                return
            }
            
        }.resume()
    }
    
    func getComments() -> Void {
        print("DEBUG: postVM.getComments")

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
                print("DEBUG: postVM.getComments error")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let getCommentsResponse = try? decoder.decode([Comment].self, from: data) else {
                print("DEBUG: postVM.getComments decode error")
                return
            }
            
            DispatchQueue.main.async {
                self.comments = getCommentsResponse
            }
        }.resume()
    }
    
    func createComment(comment: String) -> Void {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
            
        // comment API
        guard let url = URL(string: "\(API().root)comment/") else { return }
        
        let body = CreateCommentRequestBody(postId: post.id, comment: comment)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("DEBUG: postVM.createComment no data")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let commentResponse = try? decoder.decode(Comment.self, from: data) else {
                print("DEBUG: postVM.createComment decode failed")
                return
            }
            DispatchQueue.main.async {
                self.comments.append(commentResponse)
                self.post.numComments = self.post.numComments + 1
            }
        }.resume()
    }
    
    func commentReply(comment: String) -> Void {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
            
        // comment API
        guard let url = URL(string: "\(API().root)comment/") else { return }
        
        let body = CommentReplyModel.Request(postId: post.id, replyingId: replyToComment.id, comment: comment)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("DEBUG: postVM.createComment no data")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let commentResponse = try? decoder.decode(Comment.self, from: data) else {
                print("DEBUG: postVM.createComment decode failed")
                return
            }
            DispatchQueue.main.async {
                self.comments.append(commentResponse)
                self.post.numComments = self.post.numComments + 1
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
    func readPost() -> Void {
        print("DEBUG: postVM.readPost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
            print("DEBUG: postVM.readPost URL WRONG")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("DEBUG: postVM.readPost NO DATA")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let postResponse = try? decoder.decode(Post.self, from: data) else {
                print("DEBUG: postVM.readPost DECODE FAILED")
                return
            }
                
            DispatchQueue.main.async {
                self.post = postResponse
            }
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
