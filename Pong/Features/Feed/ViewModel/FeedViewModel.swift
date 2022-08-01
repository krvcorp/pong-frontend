//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var topPostsInitalOpen : Bool = false
    @Published var hotPostsInitalOpen : Bool = false
    @Published var recentPostsInitalOpen : Bool = false
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    func getPosts(selectedFilter: FeedFilterViewModel) {
        // run only on first appear
        if selectedFilter == .top {
            topPostsInitalOpen = true
        } else if selectedFilter == .hot {
            hotPostsInitalOpen = true
        } else if selectedFilter == .recent {
            recentPostsInitalOpen = true
        }

        print("DEBUG: feedVM getPosts")

        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        let url_to_use: String
        
        if selectedFilter == .recent {
            print("DEBUG: GETPOSTS Recent")
            url_to_use = "\(API().root)post/?sort=new"
        } else if selectedFilter == .top {
            print("DEBUG: GETPOSTS Top")
            url_to_use = "\(API().root)post/?sort=top"
        } else {
            print("DEBUG: GETPOSTS Default Order")
            url_to_use = "\(API().root)post/?sort=old"
        }
        
        // URL handler
        
        guard let url = URL(string: url_to_use) else { return }
        print("DEBUG: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // Task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // Convert fetch data into SWIFT JSON and store into variables
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let posts = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    if selectedFilter == .hot {
                        self!.hotPosts = posts
                    } else if selectedFilter == .recent {
                        self!.recentPosts = posts
                    } else if selectedFilter == .top {
                        self!.topPosts = posts
                    }
                }
            } catch {
                print("DEBUG: \(error)")
            }
        }
        task.resume()
    }
    
    // this logic should probably go into feedviewmodel where tapping on a post calls an API to get updated post information regarding a post
    func readPost(post: Post, completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        
        print("DEBUG: PostBubbleVM readPost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let postResponse = try? decoder.decode(Post.self, from: data) else {
                completion(.failure(.custom(errorMessage: "Decode failure")))
                return
            }
            DispatchQueue.main.async {
                // replace the local post
                if let index = self.hotPosts.firstIndex(of: post) {
                    self.hotPosts[index] = postResponse
                }
                if let index = self.recentPosts.firstIndex(of: post) {
                    self.recentPosts[index] = postResponse
                }
                if let index = self.topPosts.firstIndex(of: post) {
                    self.topPosts[index] = postResponse
                }
            }
            
            completion(.success(postResponse))
        }.resume()
    }
}
