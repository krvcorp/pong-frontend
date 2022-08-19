//
//  PollViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/30/22.
//

import Foundation

class PollViewModel : ObservableObject {
    @Published var poll: Poll = defaultPoll
    
    func sumVotes(poll: Poll) -> Int {
        
        var sum = 0
        
        for option in poll.options {
            sum = sum + option.numVotes
        }
        
        return sum
    }
    
    func pollVote(id: String, postId: String) -> Void {
        let parameters = PollVoteModel.Request(pollOptionId: id)

        NetworkManager.networkManager.request(route: "posts/\(postId)/pollvote/", method: .post, body: parameters, successType: Poll.self) { successResponse in
            // MARK: Success
            DispatchQueue.main.async {
                self.poll = successResponse
            }
        }
    }
}
