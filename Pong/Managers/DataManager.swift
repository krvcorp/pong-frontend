//
//  DataEnvironment.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/21/22.
//
// init in maintabview

import Foundation
import SwiftUI

class DataManager : ObservableObject {
    // feed
//    @Published var user : User = defaultUser
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    var topCurrentPage = "posts/?sort=top"
    var hotCurrentPage = "posts/?sort=hot"
    var recentCurrentPage = "posts/?sort=new"
    
    // profile
    @Published var profilePosts : [Post] = []
    @Published var profileComments : [ProfileComment] = []
    @Published var awards : [String] = []
    @Published var profileSavedPosts : [Post] = []
    
    // leaderboard
    @Published var leaderboardList : [TotalScore] = []
    
    // user stats
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    
    @Published var removedPost = false
    @Published var removedPostMessage = "Removed post!"
    
    func loadStartupState() {
        print("DEBUG: loadStartupState")
        // feed
        self.initTopPosts()
        self.initHotPosts()
        self.initRecentPosts()
        
        // profile
        self.initProfilePosts()
        self.initProfileComments()
        self.initAwards()
        self.initProfileSavedPosts()
        self.initUserInformation()
    }
    
    func initTopPosts() {
        let selectedFeedFilter : FeedFilter = .top
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    func initHotPosts() {
        let selectedFeedFilter : FeedFilter = .hot
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    func initRecentPosts() {
        let selectedFeedFilter : FeedFilter = .recent
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    func initSelectionPosts(selectedFeedFilter : FeedFilter) {
        var url_to_use = ""
        
        if selectedFeedFilter == .top {
            url_to_use = "posts/?sort=top"
        } else if selectedFeedFilter == .hot {
            url_to_use = "posts/?sort=hot"
        } else if selectedFeedFilter == .recent {
            url_to_use = "posts/?sort=new"
        }
        
        NetworkManager.networkManager.request(route: url_to_use, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if selectedFeedFilter == .top {

                        self.topPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                            
                        }
                    } else if selectedFeedFilter == .hot {
                        self.hotPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        }
                    } else if selectedFeedFilter == .recent {
                        self.recentPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        }
                    }
                }
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    func initProfilePosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=profile", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.profilePosts.append(contentsOf: successResponse.results)
                    let uniqued = self.profilePosts.removingDuplicates()
                    self.profilePosts = uniqued
                }
            }
        }
    }
    
    func initProfileComments() {
        NetworkManager.networkManager.request(route: "comments/?sort=profile", method: .get, successType: [ProfileComment].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.profileComments = successResponse
                }
            }
        }
    }
    
    func initAwards() {
        
    }
    
    func initProfileSavedPosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=saved", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: getSaved success")
                    self.profileSavedPosts.append(contentsOf: successResponse.results)
                }
            }
        }
    }
    
    func initUserInformation() {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: User.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.totalKarma = successResponse.totalScore
                    self.commentKarma = successResponse.commentScore
                    self.postKarma = successResponse.postScore
                }
            }
        }
    }
    
    // MARK: Helper function to delete posts
    func removePostLocally(post: Post, message: String) {
        DispatchQueue.main.async {
            withAnimation {
                if let index = self.topPosts.firstIndex(of: post) {
                    self.topPosts.remove(at: index)
                }
                if let index = self.hotPosts.firstIndex(of: post) {
                    self.hotPosts.remove(at: index)
                }
                if let index = self.recentPosts.firstIndex(of: post) {
                    self.recentPosts.remove(at: index)
                }
                if let index = self.profilePosts.firstIndex(of: post) {
                    self.profilePosts.remove(at: index)
                }
                if let index = self.profileSavedPosts.firstIndex(of: post) {
                    self.profileSavedPosts.remove(at: index)
                }
                self.removedPostMessage = message
                self.removedPost = true
            }
        }
    }
}
