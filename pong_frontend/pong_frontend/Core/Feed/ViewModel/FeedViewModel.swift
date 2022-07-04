//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var hotPosts: [Post] = []
    @Published var recentPosts: [Post] = []
    
    func getPosts(selectedFilter: FeedFilterViewModel) {
        print("DEBUG: GETPOSTS")
        
        let defaults = UserDefaults.standard
        
        guard let token = defaults.string(forKey: "jsonwebtoken") else {
                    return
                }
        
        // GET params
        let url_to_use: String
        
        if selectedFilter == .recent {
            print("DEBUG: GETPOSTS Recent")
            url_to_use = "http://127.0.0.1:8005/api/post/?recent=yes"
        } else {
            print("DEBUG: GETPOSTS Default Order")
            url_to_use = "http://127.0.0.1:8005/api/post/"
        }
        
        // URL handler
        guard let url = URL(string: url_to_use) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // Task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // Convert fetch data into SWIFT JSON and store into variables
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    if selectedFilter == .hot {
                        self?.hotPosts = posts
                    } else if selectedFilter == .recent {
                        self?.recentPosts = posts
                    }

                }
            } catch {
                print("DEBUG: \(error)")
            }
        }
        // activates api call
        task.resume()
    }
}
