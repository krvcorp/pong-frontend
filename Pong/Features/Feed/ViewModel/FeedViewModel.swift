//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI
import Alamofire

class FeedViewModel: ObservableObject {
    @Published var school : Binding<String>
    @Published var newPost = false
    @Published var isShowingNewPostSheet = false
    @Published var topPostsInitalOpen : Bool = false
    @Published var hotPostsInitalOpen : Bool = false
    @Published var recentPostsInitalOpen : Bool = false
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    init(school: Binding<String>) {
        self.school = school
    }
    
    func getPosts(selectedFilter: FeedFilterViewModel) {
        if selectedFilter == .top {
            topPostsInitalOpen = true
        } else if selectedFilter == .hot {
            hotPostsInitalOpen = true
        } else if selectedFilter == .recent {
            recentPostsInitalOpen = true
        }

        guard let token = DAKeychain.shared["token"] else { return }

        let url_to_use: String
        if selectedFilter == .recent {
            url_to_use = "\(API().root)post/?sort=new"
        } else if selectedFilter == .top {
            url_to_use = "\(API().root)post/?sort=top"
        } else {
            url_to_use = "\(API().root)post/?sort=old"
        }
        print("DEBUG: feedVM.getPosts url \(url_to_use)")
        
        guard let url = URL(string: url_to_use) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let posts = try decoder.decode([Post].self, from: data)
                
                //
                print("DEBUG: feedVM.getPosts posts \(posts)")
                DispatchQueue.main.async {
                    if selectedFilter == .hot {
                        self?.hotPosts = posts
                        print("DEBUG: \(String(describing: self?.hotPosts))")
                    } else if selectedFilter == .recent {
                        self?.recentPosts = posts
                    } else if selectedFilter == .top {
                        self?.topPosts = posts
                    }
                }
            } catch {
                print("DEBUG: feedVM.getPosts \(error)")
            }
        }
        task.resume()
    }

    func getPostsAlamofire(selectedFilter: FeedFilterViewModel) {
        let url_to_use: String
        if selectedFilter == .top {
            topPostsInitalOpen = true
            url_to_use = "\(API().root)post/?sort=top"
        } else if selectedFilter == .hot {
            hotPostsInitalOpen = true
            url_to_use = "\(API().root)post/?sort=top"
        } else if selectedFilter == .recent {
            recentPostsInitalOpen = true
            url_to_use = "\(API().root)post/?sort=new"
        } else {
            url_to_use = "\(API().root)post/?sort=old"
        }

        let method = HTTPMethod.get
        let headers: HTTPHeaders = [
            "Authorization": "Token \(DAKeychain.shared["token"])",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        AF.request(url_to_use, method: method, headers: headers).responseDecodable(of: Post.self) { response in
            guard let posts = response.value else { return }
//            if selectedFilter == .hot {
//                self!.hotPosts = posts
//            } else if selectedFilter == .recent {
//                self!.recentPosts = posts
//            } else if selectedFilter == .top {
//                self!.topPosts = posts
//            }
            debugPrint(posts)
        }
    }
    
    // this logic should probably go into feedviewmodel where tapping on a post calls an API to get updated post information regarding a post
    func readPost(postId: String, completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(postId)/") else {
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
                if let index = self.hotPosts.firstIndex(where: {$0.id == postId}) {
                    self.hotPosts[index] = postResponse
                }
                if let index = self.recentPosts.firstIndex(where: {$0.id == postId}) {
                    self.recentPosts[index] = postResponse
                }
                if let index = self.topPosts.firstIndex(where: {$0.id == postId}) {
                    self.topPosts[index] = postResponse
                }
            }
            
            completion(.success(postResponse))
        }.resume()
    }
}
