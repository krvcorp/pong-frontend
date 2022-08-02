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

    func getLoggedInUserInfo() {
        print("DEBUG: profileVM.getLoggedInUserInfo")
        guard let token = DAKeychain.shared["token"] else { return }
        guard let userId = DAKeychain.shared["userId"] else { return }

        guard let url = URL(string: "\(API().root)" + "user/" + userId + "/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let loggedInUserInfoResponse = try? decoder.decode(LoggedInUserInfoResponseBody.self, from: data) else {
                print("DEBUG: ProfileVM getLoggedInUserInfo decode error")
                return
            }
//            print("DEBUG: ProfileVM \(loggedInUserInfoResponse)")
            DispatchQueue.main.async {
                self.totalKarma = loggedInUserInfoResponse.totalScore
                self.commentKarma = loggedInUserInfoResponse.commentScore
                self.postKarma = loggedInUserInfoResponse.postScore
                self.savedPosts = loggedInUserInfoResponse.savedPosts
                self.posts = loggedInUserInfoResponse.posts
                self.comments = loggedInUserInfoResponse.comments
            }
        }.resume()
    }
}
