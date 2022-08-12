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
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse in
            // MARK: Success
            DispatchQueue.main.async {
                if let responseDataContent = successResponse.voteStatus {
                    print("DEBUG: postVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
                    DispatchQueue.main.async {
                        self.post.voteStatus = responseDataContent
                    }
                    return
                }

                if let responseDataContent = successResponse.error {
                    print("DEBUG: postVM.postVote postVoteResponse.error is \(responseDataContent)")
                    return
                }
            }
        }
    }
    
    func getComments() -> Void {
        NetworkManager.networkManager.request(route: "comments/?post_id=\(post.id)", method: .get, successType: [Comment].self) { successResponse in
            DispatchQueue.main.async {
                self.comments = successResponse
            }
        }
    }
    
    func createComment(comment: String) -> Void {
        let parameters = CommentCreateModel.Request(comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/\(post.id)/", method: .post, body: parameters, successType: Comment.self) { commentResponse in
            // MARK: Success
            DispatchQueue.main.async {
                self.comments.append(commentResponse)
                self.post.numComments = self.post.numComments + 1
            }
        }
    }
    
    func commentReply(comment: String) -> Void {
        let parameters = CommentReplyModel.Request(postId: post.id, replyingId: replyToComment.id, comment: comment)
        
        NetworkManager.networkManager.request(route: "comments/", method: .post, body: parameters, successType: Comment.self) { commentResponse in
            // MARK: Success
            DispatchQueue.main.async {
                self.comments.append(commentResponse)
                self.post.numComments = self.post.numComments + 1
            }
        }
    }
    
    // MARK: ReadPost
    func readPost() -> Void {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .get, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                // replace the local post
                self.post = successResponse
            }
        }
    }
    
    func deletePost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .delete, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func savePost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/save/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func blockPost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/block/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func reportPost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/report/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
}
