//
//  API.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

class API: ObservableObject {
    @Published var posts: [Post] = []
    
    func getPosts() {
        // url handler
        guard let url = URL(string: "http://127.0.0.1:8005/api/getPosts/") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self?.posts = posts
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
}
