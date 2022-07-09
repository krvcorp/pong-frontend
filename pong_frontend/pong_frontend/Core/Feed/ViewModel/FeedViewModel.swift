//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var topPosts: [Post] = []
    @Published var hotPosts: [Post] = []
    @Published var recentPosts: [Post] = []
    
    func getPosts(selectedFilter: FeedFilterViewModel) {
        print("DEBUG: GETPOSTS")

        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        print("DEBUG: FeedVM KEYCHAIN TOKEN IS \(token)")
        
        // GET params
        let url_to_use: String
        
        if selectedFilter == .recent {
            print("DEBUG: GETPOSTS Recent")
            url_to_use = "http://127.0.0.1:8005/api/post/?sort=new"
        } else if selectedFilter == .top {
            print("DEBUG: GETPOSTS Top")
            url_to_use = "http://127.0.0.1:8005/api/post/?sort=top"
        } else {
            print("DEBUG: GETPOSTS Default Order")
            url_to_use = "http://127.0.0.1:8005/api/post/?sort=old"
        }
        
        // URL handler
        
        guard let url = URL(string: url_to_use) else { return }
        debugPrint(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // Task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // Convert fetch data into SWIFT JSON and store into variables
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                debugPrint(posts)
                DispatchQueue.main.async {
                    if selectedFilter == .hot {
                        self?.hotPosts = posts
                    } else if selectedFilter == .recent {
                        debugPrint("in here")
                        self?.recentPosts = posts
                    } else if selectedFilter == .top {
                        self?.topPosts = posts
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
