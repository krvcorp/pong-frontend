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
    @Published var postVotes: Votes = Votes(votes: 0)
    @Published var commentVotes: Votes = Votes(votes: 0)
    
    // LIST OF OBJECTS
    func getPostVotes(postid: Int) {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/getPostVotes/\(postid)/") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let postVotes = try JSONDecoder().decode(Votes.self, from: data)
                DispatchQueue.main.async {
                    self?.postVotes = postVotes
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
    
    func getCommentVotes(commentid: Int) {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/getCommentVotes/\(commentid)/") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let commentVotes = try JSONDecoder().decode(Votes.self, from: data)
                DispatchQueue.main.async {
                    self?.commentVotes = commentVotes
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
}
