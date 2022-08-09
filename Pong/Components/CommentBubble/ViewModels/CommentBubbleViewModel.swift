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
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)commentvote/") else { return }
        
        var voteToSend = 0
        if direction == comment.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        print("DEBUG: commentBubbleVM.commentVote \(voteToSend)")

        let body = CommentVoteModel.Request(commentId: comment.id, vote: voteToSend)
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                print("DEBUG: commentBubbleVM.commentVote no data")
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let commentVoteResponse = try? decoder.decode(CommentVoteModel.Response.self, from: data!) else {
                print("DEBUG: commentBubbleVM.commentVote Decode Error")
                return
            }

            if let responseDataContent = commentVoteResponse.voteStatus {
                print("DEBUG: commentBubbleVM.commentVote commentVoteResponse.voteStatus is \(responseDataContent)")
                DispatchQueue.main.async {
                    self.comment.voteStatus = responseDataContent
                }
                return
            }

            if let responseDataContent = commentVoteResponse.error {
                print("DEBUG: commentBubbleVM.commentVote commentVoteResponse.error is \(responseDataContent)")
                return
            }
            
            print("DEBUG: commentBubbleVM.commentVote nothing")

        }.resume()
    }
}
