//
//  ProfileViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/9/22.
//

import Foundation

enum ProfileFilter: String, CaseIterable, Identifiable {
    case posts, saved
    var id: Self { self }
}

class ProfileViewModel: ObservableObject {
    @Published var selectedProfileFilter : ProfileFilter = .posts
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var savedPosts: [Post] = []

    func getLoggedInUserInfo() {
        print("DEBUG: profileVM.getLoggedInUserInfo")
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: LoggedInUserInfoResponseBody.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.totalKarma = successResponse.totalScore
                    self.commentKarma = successResponse.commentScore
                    self.postKarma = successResponse.postScore
                    self.savedPosts = successResponse.savedPosts
                    self.posts = successResponse.posts
                    self.comments = successResponse.comments
                    print("DEBUG: profileVM.getLoggedInUserInfo total karma \(self.totalKarma)")
                }
            }
        }
    }
}
