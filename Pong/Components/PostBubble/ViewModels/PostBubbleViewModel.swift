//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    init(post: Post) {
        self.post = post
    }
    
    func postVote(direction: Int, completion: @escaping (Result<PostVoteModel.Response, AuthenticationError>) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)postvote/") else { return }
        
        var voteToSend = 0
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let body = PostVoteModel.Request(postId: post.id, vote: voteToSend)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            guard let postVoteResponse = try? decoder.decode(PostVoteModel.Response.self, from: data!) else {
                completion(.failure(.decodeError))
                return
            }

            if let responseDataContent = postVoteResponse.voteStatus {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.voteStatus is \(responseDataContent)")
                completion(.success(postVoteResponse))
                return
            }

            if let responseDataContent = postVoteResponse.error {
                print("DEBUG: postBubbleVM.postVote postVoteResponse.error is \(responseDataContent)")
                completion(.success(postVoteResponse))
                return
            }
            completion(.failure(.custom(errorMessage: "Nothing")))
            
        }.resume()
    }
}
