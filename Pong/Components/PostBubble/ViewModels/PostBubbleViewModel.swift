//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    @Published var showDeleteConfirmationView : Bool = false
    
    
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
                    print("DEBUG: postBubbleVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
                    DispatchQueue.main.async {
                        self.post.voteStatus = responseDataContent
                    }
                    return
                }

                if let responseDataContent = successResponse.error {
                    print("DEBUG: postBubbleVM.postVote postVoteResponse.error is \(responseDataContent)")
                    return
                }
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
                print("DEBUG: postBubbleVM.savePost")
                self.post.saved = true
            }
        }
    }
    
    func unsavePost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/save/", method: .delete, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: postBubbleVM.unsavePost")
                self.post.saved = false
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
