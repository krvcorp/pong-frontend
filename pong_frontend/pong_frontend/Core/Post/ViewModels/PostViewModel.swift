//
//  PostViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    // LIST OF OBJECTS
    func getCommentsOfPost(postid: Int) {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/getCommentsOfPost/\(postid)/") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let comments = try decoder.decode([Comment].self, from: data)
                DispatchQueue.main.async {
                    self?.comments = comments
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
}
