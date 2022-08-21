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
    @Published var savedPostConfirmation : Bool = false
    
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
    
    func savePost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = true
                    self.savedPostConfirmation = true
                }
            }
        }
    }
    
    func unsavePost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = false
                }
            }
        }
    }
    
    func deletePost(post: Post, feedVM: FeedViewModel) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                feedVM.deletePost(post: post)
            }
        }
    }
    
    func blockPost(post: Post, feedVM: FeedViewModel) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                feedVM.blockPost(post: post)
            }
        }
    }
    
    func reportPost(post: Post, feedVM: FeedViewModel) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                feedVM.reportPost(post: post)
            }
        }
    }
}
