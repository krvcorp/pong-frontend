//
//  CommentBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/1/22.
//

import Foundation

class CommentBubbleViewModel: ObservableObject {
    @Published var comment : Comment = defaultComment
    
    // MARK: CommentVote
    func commentVote(direction: Int) -> Void {
        
        var voteToSend = 0
        if direction == comment.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        print("DEBUG: commentBubbleVM.commentVote \(voteToSend)")
        
        let parameters = CommentVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/vote/", method: .post, body: parameters, successType: CommentVoteModel.Response.self) { successResponse in
            // MARK: Success
            DispatchQueue.main.async {
                if let responseDataContent = successResponse.voteStatus {
                    print("DEBUG: commentBubbleVM.commentVote commentVoteResponse.voteStatus is \(responseDataContent)")
                    DispatchQueue.main.async {
                        self.comment.voteStatus = responseDataContent
                    }
                    return
                }

                if let responseDataContent = successResponse.error {
                    print("DEBUG: commentBubbleVM.commentVote commentVoteResponse.error is \(responseDataContent)")
                    return
                }
            }
        }
    }
    
    func deleteComment() {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/", method: .delete, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func saveComment() {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/save/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func blockComment() {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/block/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func reportComment() {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/report/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
}
