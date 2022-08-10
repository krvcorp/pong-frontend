//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    func postVote(direction: Int) -> Void {
        var voteToSend = 0
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(postId: post.id, vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "postvote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse in
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
}
