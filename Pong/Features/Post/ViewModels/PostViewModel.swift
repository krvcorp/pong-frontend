//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation
import SwiftUI

enum PostViewActiveAlert {
    case postDelete, postReport, postBlock, commentDelete, commentReport, commentBlock, pushNotifications
}

class PostViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    @Published var comments : [Comment] = []
    
    @Published var showConfirmation : Bool = false
    @Published var activeAlert : PostViewActiveAlert = .postDelete
    
    @Published var commentToDelete : Comment = defaultComment
    @Published var replyToComment : Comment = defaultComment
    
    @Published var savedPostConfirmation : Bool = false
    
    @Published var commentsLoaded = false
    
    @Published var postUpdateTrigger = false
    @Published var commentUpdateTrigger = false
    
    @Published var textIsFocused = false
    
    @Published var openConversations = false
    
    func postVote(direction: Int, dataManager: DataManager) -> Void {
        var voteToSend = 0
        let temp = self.post.voteStatus
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        DispatchQueue.main.async {
            self.post.voteStatus = voteToSend
            self.postUpdateTrigger.toggle()
        }
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if successResponse != nil {
                    
                }
                
                if errorResponse != nil {
                    self.post.voteStatus = temp
                    self.postUpdateTrigger.toggle()
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't vote on post")
                }
            }
        }
    }
    
    func getComments() -> Void {
        NetworkManager.networkManager.request(route: "comments/?post_id=\(post.id)", method: .get, successType: CommentListModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.comments = successResponse.results
                    self.commentsLoaded = true
                    self.commentUpdateTrigger.toggle()
                }
            }
        }
    }
    
    func createComment(comment: String, dataManager: DataManager, notificationsManager: NotificationsManager) -> Void {
        let parameters = CommentCreateModel.Request(postId: self.post.id, comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    withAnimation {
                        if !notificationsManager.hasEnabledNotificationsOnce {
                            self.activeAlert = .pushNotifications
                            self.showConfirmation = true
                        }
                        self.comments.append(successResponse)
                        self.post.numComments = self.post.numComments + 1
                        self.commentUpdateTrigger.toggle()
                        dataManager.initProfile()
                    }
                }
            }
        }
    }
    
    func commentReply(comment: String, dataManager: DataManager, notificationsManager: NotificationsManager) -> Void {
        let parameters = CommentReplyModel.Request(postId: post.id, replyingId: replyToComment.id, comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
            // MARK: Success
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if !notificationsManager.hasEnabledNotificationsOnce {
                        self.activeAlert = .pushNotifications
                        self.showConfirmation = true
                    }
                    for (index, comment) in self.comments.enumerated() {
                        if successResponse.parent == comment.id {
                            withAnimation {
                                self.comments[index].children.append(successResponse)
                            }
                        }
                    }
                    self.post.numComments = self.post.numComments + 1
                }
            } else if errorResponse != nil {
                DispatchQueue.main.async {
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't create comment reply")
                }
            }
        }
    }
    
    func setCommentReply(comment: Comment) {
        if self.replyToComment != comment {
            self.textIsFocused = true
        } else {
            self.textIsFocused.toggle()
        }

        self.replyToComment = comment
    }
    
    // MARK: ReadPost
    func readPost(dataManager : DataManager, completion: @escaping (Bool) -> Void) {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    // replace the local post
                    self.post = successResponse
//                    self.postUpdateTrigger.toggle()
                }
            }
            
            if errorResponse != nil {
                DispatchQueue.main.async {
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't read post")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Save Post
    func savePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            self.post = post
            self.post.saved = true
            self.savedPostConfirmation = true
            self.postUpdateTrigger.toggle()
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                
            } else if errorResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = false
                    self.postUpdateTrigger.toggle()
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't save post")
                }
            }
        }
    }
    
    func unsavePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            self.post = post
            self.post.saved = false
            self.postUpdateTrigger.toggle()
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                
            } else if errorResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = true
                    self.postUpdateTrigger.toggle()
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't unsave post")
                }
            }
        }
    }
    
    func deletePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Deleted post!")
                self.postUpdateTrigger.toggle()
            }
        }
    }
    
    // MARK: Comments Related Stuff
    func deleteComment(comment: Comment) {
        DispatchQueue.main.async {
            self.commentToDelete = comment
            self.activeAlert = .commentDelete
            self.showConfirmation = true
        }
    }
    
    func blockComment(comment: Comment) {
        DispatchQueue.main.async {
            self.commentToDelete = comment
            self.activeAlert = .commentBlock
            self.showConfirmation = true
        }
    }
    
    func reportComment(comment: Comment) {
        DispatchQueue.main.async {
            self.commentToDelete = comment
            self.activeAlert = .commentReport
            self.showConfirmation = true
        }
    }
    
    func deleteCommentConfirm(dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.commentToDelete.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        if (self.commentToDelete.parent != nil){
                            if let index = self.comments.firstIndex(where: {$0.id == self.commentToDelete.parent!}) {
                                if let toDeleteIndex = self.comments[index].children.firstIndex(where: {$0.id == self.commentToDelete.id}) {
                                    self.comments[index].children.remove(at: toDeleteIndex)
                                }
                            }
                        }
                        else {
                            if let index = self.comments.firstIndex(of: self.commentToDelete) {
                                self.comments.remove(at: index)
                            }
                        }
                    }
                    if self.activeAlert == .commentReport {
                        dataManager.removedCommentMessage = "Comment reported!"
                    } else if self.activeAlert == .commentBlock {
                        dataManager.removedCommentMessage = "User blocked!"
                    } else if self.activeAlert == .commentDelete {
                        dataManager.removedCommentMessage = "Comment deleted!"
                    } else {
                        dataManager.removedCommentMessage = "Comment removed!"
                    }
                    dataManager.removedComment = true
                    self.post.numComments -= 1
                    self.commentUpdateTrigger.toggle()
                    dataManager.removeCommentLocally(commentId: self.commentToDelete.id, message: "Deleted comment")
                }
            } else if errorResponse != nil {
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't delete post")
            }
        }
    }
    
    func blockPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Blocked user!")
                self.postUpdateTrigger.toggle()
            } else if errorResponse != nil {
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't block post")
            }
        }
    }
    
    func reportPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Reported post!")
                self.postUpdateTrigger.toggle()
            } else if errorResponse != nil {
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't report post")
            }
        }
    }
    
    func updateCommentLocally(comment: Comment) {
        DispatchQueue.main.async {
            if let index = self.comments.firstIndex(where: {$0.id == comment.id}) {
                self.comments[index] = comment
            }
        }
    }
    
    func startConversation(post: Post, dataManager: DataManager, completion: @escaping (Conversation) -> Void) {
        let parameters = CreateConversation.RequestPost(postId: post.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                completion(successResponse)
            }
        }
    }
    
    func startConversation(comment: Comment, dataManager: DataManager, completion: @escaping (Conversation) -> Void) {
        let parameters = CreateConversation.RequestComment(commentId: comment.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                completion(successResponse)
            }
        }
    }
}
