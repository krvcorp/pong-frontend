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
        var voteToSend = 0
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
            // MARK: Success
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    self.post.voteStatus = successResponse.voteStatus
                }
                
                if let errorResponse = errorResponse {
                    print("DEBUG: \(errorResponse)")
                }
            }
        }
    }
    
    func getComments() -> Void {
        NetworkManager.networkManager.request(route: "comments/?post_id=\(post.id)", method: .get, successType: [Comment].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.comments = successResponse
                }
            }
        }
    }
    
    func createComment(comment: String) -> Void {
        let parameters = CommentCreateModel.Request(comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/\(post.id)/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
            // MARK: Success
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.comments.append(successResponse)
                    self.post.numComments = self.post.numComments + 1
                }
            }
        }
    }
    
    func commentReply(comment: String) -> Void {
        let parameters = CommentReplyModel.Request(postId: post.id, replyingId: replyToComment.id, comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
            // MARK: Success
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    for (index, comment) in self.comments.enumerated() {
                        if successResponse.parent == comment.id {
                            print("DEBUG: postVM.commentReply append")
                            self.comments[index].children.append(successResponse)
                        }
                    }
                    self.post.numComments = self.post.numComments + 1
                }
            }
        }
    }
    
    // MARK: ReadPost
    func readPost() -> Void {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    // replace the local post
                    self.post = successResponse
                }
            }
        }
    }
    
    func deletePost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .delete, successType: Post.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func savePost() {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func blockPost() {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func reportPost() {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
}
