//
//  ProfileViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/9/22.
//

import Foundation

enum ProfileFilter: String, CaseIterable, Identifiable {
    case posts, comments, awards, saved
    var id: Self { self }
    
    var title: String {
        switch self {
        case .posts: return "Posts"
        case .comments: return "Comments"
        case .awards: return "Awards"
        case .saved: return "Saved"
        }
    }
    
    var imageName: String {
        switch self {
        case .posts: return "square.grid.2x2"
        case .comments: return "arrowshape.turn.up.left.2"
        case .awards: return "seal"
        case .saved: return "bookmark"
        }
    }
    
    var filledImageName: String {
        switch self {
        case .posts: return "square.grid.2x2.fill"
        case .comments: return "arrowshape.turn.up.left.2.fill"
        case .awards: return "seal.fill"
        case .saved: return "bookmark.fill"
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var selectedProfileFilter : ProfileFilter = .posts
    
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    
    @Published var posts: [Post] = []
    @Published var comments: [ProfileComment] = []
    @Published var awards: [Post] = []
    @Published var saved: [Post] = []
    
    @Published var savedPosts: [Post] = []

    func getProfile(dataManager: DataManager) {
        getPosts(dataManager: dataManager)
        getUser(dataManager: dataManager)
        getSaved(dataManager: dataManager)
        getAwards(dataManager: dataManager)
        getComments(dataManager: dataManager)
    }
    
    func getUser(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: User.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: getUser success")
                    self.totalKarma = successResponse.totalScore
                    self.commentKarma = successResponse.commentScore
                    self.postKarma = successResponse.postScore
                }
            }
        }
    }
    
    func getPosts(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: "posts/?sort=profile", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.profilePosts.append(contentsOf: successResponse.results)
                    let uniqued = dataManager.profilePosts.removingDuplicates()
                    dataManager.profilePosts = uniqued
                }
            }
        }
    }
    
    func getComments(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: "comments/?sort=profile", method: .get, successType: [ProfileComment].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: getComments success")
                    dataManager.profileComments = successResponse
                }
            }
        }
    }
    
    func getAwards(dataManager : DataManager) {
        print("DEBUG: Get Awards")
    }
    
    func getSaved(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: "posts/?sort=saved", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: getSaved success")
                    dataManager.profileSavedPosts.append(contentsOf: successResponse.results)
                }
            }
        }
    }
    
    func triggerRefresh(tab: ProfileFilter, dataManager: DataManager) {
        if tab == .posts {
            getPosts(dataManager: dataManager)
        } else if tab == .comments {
            getPosts(dataManager: dataManager)
        } else if tab == .awards {
            getPosts(dataManager: dataManager)
        } else if tab == .saved {
            getPosts(dataManager: dataManager)
        }
    }
}
