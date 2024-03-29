//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation
import SwiftUI
import UIKit
import Alamofire

enum PostViewActiveAlert {
    case postDelete, postReport, postBlock, commentDelete, commentReport, commentBlock
}

class PostViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    @Published var showConfirmation : Bool = false
    @Published var activeAlert : PostViewActiveAlert = .postDelete
    
    @Published var commentImage : UIImage? = nil
    
    @Published var commentToDelete : Comment = defaultComment
    @Published var replyToComment : Comment = defaultComment
    
    @Published var savedPostConfirmation : Bool = false
    
    @Published var postUpdateTrigger = false
    @Published var commentUpdateTrigger = false
    
    @Published var textIsFocused = false
    
    @Published var openConversations = false
    
    // MARK: PostVote
    func postVote(direction: Int, post: Post, dataManager: DataManager) -> Void {
        self.post = post

        var voteToSend = 0
        let temp = self.post.voteStatus
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        DispatchQueue.main.async {
            self.post = post
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
                }
            }
        }
    }
    

    // MARK: GetComments
    func getComments(completion: @escaping ([Comment]) -> Void) {
        NetworkManager.networkManager.request(route: "comments/?post_id=\(post.id)", method: .get, successType: CommentListModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.commentUpdateTrigger.toggle()
                    completion(successResponse.results)
                }
            }
        }
    }
    
    // MARK: CreateComment
    func createComment(post: Post, comment: String, dataManager: DataManager, notificationsManager: NotificationsManager, completion: @escaping (Bool) -> Void) {
        let parameters = CommentCreateModel.Request(postId: post.id, comment: comment)
        
        // WITH IMAGE
        if self.commentImage != nil {
            let imgData = (commentImage!).jpegData(compressionQuality: 0.2)!

            var httpHeaders: HTTPHeaders = []

            if let token = DAKeychain.shared["token"] {
                httpHeaders = [
                    "Authorization": "Token \(token)"
                ]
            }
            
            let decoder: JSONDecoder = {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }()
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(post.id.data(using: String.Encoding.utf8)!, withName: "post_id")
                multipartFormData.append(imgData, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
                multipartFormData.append(comment.data(using: String.Encoding.utf8)!, withName: "comment")
            }, to: "\(NetworkManager.networkManager.baseURL)comments/", method: .post, headers: httpHeaders)
                // specific success response
                .responseDecodable(of: Comment.self, decoder: decoder) { (successResponse) in
                    if let successResponse = successResponse.value {
                        DispatchQueue.main.async {
                            NotificationsManager.shared.registerForNotifications(forceRegister: false)
                            if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                                dataManager.postComments[index].1.insert(successResponse, at: 0)
                            }
                            self.commentImage = nil
                            self.commentUpdateTrigger.toggle()
                            dataManager.initProfile()
                            self.post.numComments += 1
                            completion(true)
                        }
                    }
                }
                // specific error response
                .responseDecodable(of: ErrorResponseBody.self, decoder: decoder) { (errorResponse) in
                    if errorResponse.value != nil {
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
            
        }
        // NO IMAGE
        else {
            NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    DispatchQueue.main.async {
                        NotificationsManager.shared.registerForNotifications(forceRegister: false)
                        if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                            dataManager.postComments[index].1.insert(successResponse, at: 0)
                        }
                        self.commentUpdateTrigger.toggle()
                        dataManager.initProfile()
                        self.post.numComments += 1
                        completion(true)
                    }
                }
                
                if errorResponse != nil {
                    
                }
            }
        }
    }
    
    // MARK: CommentReply
    func commentReply(post: Post, comment: String, dataManager: DataManager, notificationsManager: NotificationsManager, completion: @escaping (Bool) -> Void) {
        let parameters = CommentReplyModel.Request(postId: post.id, replyingId: replyToComment.id, comment: comment)
        
        // WITH IMAGE
        if self.commentImage != nil {
            let imgData = (commentImage!).jpegData(compressionQuality: 0.2)!

            var httpHeaders: HTTPHeaders = []

            if let token = DAKeychain.shared["token"] {
                httpHeaders = [
                    "Authorization": "Token \(token)"
                ]
            }
            
            let decoder: JSONDecoder = {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }()
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(post.id.data(using: String.Encoding.utf8)!, withName: "post_id")
                multipartFormData.append(self.replyToComment.id.data(using: String.Encoding.utf8)!, withName: "replying_id")
                multipartFormData.append(comment.data(using: String.Encoding.utf8)!, withName: "comment")
                multipartFormData.append(imgData, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
            }, to: "\(NetworkManager.networkManager.baseURL)comments/", method: .post, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        }
                    }
                }
                // success response
                .responseDecodable(of: Comment.self, decoder: decoder) { (successResponse) in
                    if let successResponse = successResponse.value {
                        DispatchQueue.main.async {
                            NotificationsManager.shared.registerForNotifications(forceRegister: false)
                            if let index1 = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                                if let index2 = dataManager.postComments[index1].1.firstIndex(where: {$0.id == successResponse.parent}) {
                                        dataManager.postComments[index1].1[index2].children.insert(successResponse, at: 0)
                                }
                            }
                            self.commentImage = nil
                            self.commentUpdateTrigger.toggle()
                            dataManager.initProfile()
                            self.replyToComment = defaultComment
                            self.post.numComments += 1
                            completion(true)
                        }
                    }
                }
                // specific error response
                .responseDecodable(of: ErrorResponseBody.self, decoder: decoder) { (errorResponse) in
                    if errorResponse.value != nil {
                        DispatchQueue.main.async {
                            ToastManager.shared.errorToastDetected(message: "Something went wrong", subMessage: "Unable to make a comment")
                        }
                    }
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            ToastManager.shared.errorToastDetected(message: "Something went wrong", subMessage: "Unable to make a comment")
                        }
                        break
                    }
                }
                // tracking http errors
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong", subMessage: "\(httpStatusCode)")
                        }
                    }
                }
        }
        // NO IMAGE
        else {
            NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    DispatchQueue.main.async {
                        NotificationsManager.shared.registerForNotifications(forceRegister: false)
                        
                        if let index1 = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                            if let index2 = dataManager.postComments[index1].1.firstIndex(where: {$0.id == successResponse.parent}) {
                                dataManager.postComments[index1].1[index2].children.insert(successResponse, at: 0)
                            }
                        }
                        self.post.numComments += 1
                        self.replyToComment = defaultComment
                        self.commentUpdateTrigger.toggle()
                        dataManager.initProfile()
                        completion(true)
                    }
                }
                
                if errorResponse != nil {
                    
                }
            }
        }
    }
    
    // MARK: SetCommentReply
    func setCommentReply(comment: Comment) {
        if self.replyToComment != comment {
            self.textIsFocused = true
        } else {
            self.textIsFocused.toggle()
        }

        self.replyToComment = comment
    }
    
    // MARK: ReadPost
    func readPost(post : Post, dataManager : DataManager, completion: @escaping (Bool) -> Void) {
        self.post = post
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    // replace the local post
                    self.post = successResponse
                    completion(true)
                    return
                }
            }
            
            if errorResponse != nil {
                DispatchQueue.main.async {
                    completion(false)
                    return
                }
            }
        }
    }
    
    // MARK: Save Post
    func savePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            withAnimation {
                self.post = post
                self.post.saved = true
                self.savedPostConfirmation = true
                self.postUpdateTrigger.toggle()
            }
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                
            } else if errorResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = false
                    self.postUpdateTrigger.toggle()
                }
            }
        }
    }
    
    // MARK: Unsave Post
    func unsavePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            withAnimation {
                self.post = post
                self.post.saved = false
                self.postUpdateTrigger.toggle()
            }
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                
            }
            
            if errorResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = true
                    self.postUpdateTrigger.toggle()
                }
            }
        }
    }
    
    // MARK: DeletePost
    func deletePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/", method: .delete) { successResponse, errorResponse in
            
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Deleted post!")
                self.postUpdateTrigger.toggle()
            }
            
            if errorResponse != nil {
                
            }
        }
    }
    
    // MARK: BlockPost
    func blockPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Blocked user!")
                self.postUpdateTrigger.toggle()
            }
            
            if errorResponse != nil {
                
            }
        }
    }
    
    // MARK: ReportPost
    func reportPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Reported post!")
                self.postUpdateTrigger.toggle()
            }
            
            if errorResponse != nil {
                
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
    
    // MARK: Removing Comment Stuff
    
    // MARK: DeleteCommentConfirm
    func deleteCommentConfirm(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.commentToDelete.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.removeCommentLocally(post: post, dataManager: dataManager)
                    self.commentUpdateTrigger.toggle()
                    dataManager.removeCommentLocally(commentId: self.commentToDelete.id, message: "Deleted comment")
                    
                    // ALERTS
                    ToastManager.shared.toastDetected(message: "Comment deleted!")
                }
            }
            
            if errorResponse != nil {
                
            }
        }
    }
    
    // MARK: ReportCommentConfirm
    func reportCommentConfirm(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.commentToDelete.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.removeCommentLocally(post: post, dataManager: dataManager)
                    self.commentUpdateTrigger.toggle()
                    dataManager.removeCommentLocally(commentId: self.commentToDelete.id, message: "Reported comment")
                    
                    // ALERTS
                    ToastManager.shared.toastDetected(message: "Comment reported!")
                }
            }
            
            if errorResponse != nil {
                
            }
        }
    }
    
    // MARK: BlockCommentConfirm
    func blockCommentConfirm(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.commentToDelete.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.removeCommentLocally(post: post, dataManager: dataManager)
                    self.commentUpdateTrigger.toggle()
                    dataManager.removeCommentLocally(commentId: self.commentToDelete.id, message: "Blocked comment")
                    
                    // ALERTS
                    ToastManager.shared.toastDetected(message: "Comment blocked!")
                }
            }
            
            if errorResponse != nil {
                    
            }
        }
    }
    
    // MARK: RemoveCommentLocally Helper Function
    func removeCommentLocally(post: Post, dataManager: DataManager) {
        withAnimation {
            if (self.commentToDelete.parent != nil) {
                if let index1 = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                    if let index2 = dataManager.postComments[index1].1.firstIndex(where: {$0.id == self.commentToDelete.parent}) {
                        if let index3 = dataManager.postComments[index1].1[index2].children.firstIndex(where: {$0.id == self.commentToDelete.id}) {
                            dataManager.postComments[index1].1[index2].children.remove(at: index3)
                        }
                    }
                }
            }
            else {
                if let index1 = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                    if let index2 = dataManager.postComments[index1].1.firstIndex(where: {$0.id == self.commentToDelete.id}) {
                        dataManager.postComments[index1].1.remove(at: index2)
                    }
                }
            }
        }
    }
    
    // MARK: StartConversation via Post
    func startConversation(post: Post, dataManager: DataManager, completion: @escaping (Conversation) -> Void) {
        let parameters = CreateConversation.RequestPost(postId: post.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                completion(successResponse)
            }
        }
    }
    
    // MARK: StartConversation via Comment
    func startConversation(comment: Comment, dataManager: DataManager, completion: @escaping (Conversation) -> Void) {
        let parameters = CreateConversation.RequestComment(commentId: comment.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                completion(successResponse)
            }
        }
    }
}
