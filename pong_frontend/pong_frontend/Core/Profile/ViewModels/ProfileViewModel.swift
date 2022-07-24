//
//  ProfileViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/9/22.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var savedPosts: [Post] = []

//    func getPosts() {
//        guard let token = DAKeychain.shared["token"] else { return }
//        guard let url = URL(string: "\(API().root)" + "post/") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let data = data, error == nil else { return }
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let posts = try decoder.decode([Post].self, from: data)
//                DispatchQueue.main.async {
//                    self?.posts = posts
//                }
//            } catch {
//                print("DEBUG: \(error)")
//            }
//        }
//        task.resume()
//    }
//
//    func getComments() {
//        guard let token = DAKeychain.shared["token"] else { return }
//        guard let url = URL(string: "\(API().root)" + "comment/") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let data = data, error == nil else { return }
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let comments = try decoder.decode([Comment].self, from: data)
//                DispatchQueue.main.async {
//                    self?.comments = comments
//                }
//            } catch {
//                print("DEBUG: \(error)")
//            }
//        }
//        task.resume()
//    }

    func getLoggedInUserInfo() {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let userId = DAKeychain.shared["userId"] else { return }

        guard let url = URL(string: "\(API().root)" + "user/" + userId + "/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let loggedInUserInfoResponse = try? decoder.decode(LoggedInUserInfoResponseBody.self, from: data) else {
                return
            }
            
            debugPrint(loggedInUserInfoResponse.savedPosts)


            self.totalKarma = loggedInUserInfoResponse.totalKarma
            self.commentKarma = loggedInUserInfoResponse.commentKarma
            self.postKarma = loggedInUserInfoResponse.postKarma
            self.savedPosts = loggedInUserInfoResponse.savedPosts
            self.posts = loggedInUserInfoResponse.posts
            self.comments = loggedInUserInfoResponse.comments
            

        }.resume()
    }
}
