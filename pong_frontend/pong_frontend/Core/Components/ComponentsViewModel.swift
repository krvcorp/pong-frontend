//
//  ComponentsViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
struct Votes: Codable, Hashable {
    var votes: Int
}


import Foundation

class ComponentsViewModel: ObservableObject {
    func createPostVote(postid: Int, direction: String) {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/createPostVote/\(postid)/\(direction)/") else { return }

        // something about request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
        }
        // activates api call
        task.resume()
    }
}
