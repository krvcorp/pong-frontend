//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation
import SwiftUI

class PostViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    @Published var comments : [Comment] = []
    @Published var showDeletePostConfirmationView : Bool = false
    @Published var showDeleteCommentConfirmationView : Bool = false
    @Published var commentToDelete : Comment = defaultComment
    @Published var replyToComment : Comment = defaultComment
    @Published var savedPostConfirmation : Bool = false
    
    @Published var readPostPreventDupes = true
    @Published var getCommentsPreventDupes = true
    
    func postVote(direction: Int) -> Void {
        var voteToSend = 0
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
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
        if getCommentsPreventDupes {
            self.getCommentsPreventDupes = false
            NetworkManager.networkManager.request(route: "comments/?post_id=\(post.id)", method: .get, successType: [Comment].self) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    DispatchQueue.main.async {
                        self.comments = successResponse
                    }
                }
                self.getCommentsPreventDupes = true
            }
        } else {
            print("DEBUG: Duplicate network request detected and killed")
        }
    }
    
    func createComment(comment: String) -> Void {
        let parameters = CommentCreateModel.Request(postId: self.post.id, comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    withAnimation {
                        self.comments.append(successResponse)
                        self.post.numComments = self.post.numComments + 1
                    }
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
                            withAnimation {
                                self.comments[index].children.append(successResponse)
                            }
                        }
                    }
                    self.post.numComments = self.post.numComments + 1
                }
            }
        }
    }
    
    // MARK: ReadPost
    func readPost() -> Void {
        if readPostPreventDupes {
            self.readPostPreventDupes = false
            NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .get, successType: Post.self) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    DispatchQueue.main.async {
                        // replace the local post
                        self.post = successResponse
                    }
                }
                self.readPostPreventDupes = true
            }
        }
    }
    
    // MARK: Save Post
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
    
    // MARK: Comments Related Stuff
    func deleteComment(comment: Comment) {
        DispatchQueue.main.async {
            self.commentToDelete = comment
            self.showDeleteCommentConfirmationView = true
        }
    }
    
    func deleteCommentConfirm() {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.commentToDelete.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        if let index = self.comments.firstIndex(of: self.commentToDelete) {
                            self.comments.remove(at: index)
                        }
                    }
                }
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
