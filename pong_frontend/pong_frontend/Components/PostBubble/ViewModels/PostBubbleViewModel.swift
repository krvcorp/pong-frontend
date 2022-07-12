//
//  PostBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/12/22.
//

import Foundation

class PostBubbleViewModel: ObservableObject {
    func createPostVote(postid: String, direction: String) {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/createPostVote/\(postid)/\(direction)/") else { return }

        // something about request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
        }
        // activates api call
        task.resume()
    }
}
