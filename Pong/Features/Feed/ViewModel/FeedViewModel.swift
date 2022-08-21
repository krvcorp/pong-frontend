//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI
import Alamofire
import Combine

enum FeedFilter: String, CaseIterable, Identifiable {
    case top, hot, recent
    var id: Self { self }
    
    var title: String {
        switch self {
        case .top: return "Top"
        case .hot: return "Hot"
        case .recent: return "Recent"
        }
    }
    
    var imageName: String {
        switch self {
        case .top: return "chart.bar"
        case .hot: return "flame"
        case .recent: return "clock"
        }
    }
    
    var filledImageName: String {
        switch self {
        case .top: return "chart.bar.fill"
        case .hot: return "flame.fill"
        case .recent: return "clock.fill"
        }
    }
}

enum TopFilter: String, CaseIterable, Identifiable {
    case allTime, thisYear, thisMonth, thisWeek, today
    var id: Self { self }
    
    var title: String {
        switch self {
        case .allTime: return "TOP POSTS ALL TIME"
        case .thisYear: return "TOP POSTS THIS YEAR"
        case .thisMonth: return "TOP POSTS THIS MONTH"
        case .thisWeek: return "TOP POSTS THIS YEAR"
        case .today: return "TOP POSTS TODAY"
        }
    }
}

class FeedViewModel: ObservableObject {
    @Published var selectedFeedFilter : FeedFilter = .hot
    @Published var school = "Boston University"
    @Published var InitalOpen : Bool = true
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    @Published var selectedTopFilter : TopFilter = .allTime
    
    @Published var finishedTop = false
    @Published var finishedHot = false
    @Published var finishedRecent = false
    
    @Published var removedPost = false
    @Published var removedPostType = "default"
    
    //MARK: Pagination
    var topCurrentPage = "posts/?sort=top"
    
    var hotCurrentPage = "posts/?sort=hot"
    
    var recentCurrentPage = "posts/?sort=new"
    
    func paginatePostsIfNeeded(post: Post, selectedFeedFilter: FeedFilter) {
        let offsetBy = -15

        if selectedFeedFilter == .top {
            let thresholdIndex = topPosts.index(topPosts.endIndex, offsetBy: offsetBy)
            if topPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter)
            }
        } else if selectedFeedFilter == .hot {
            let thresholdIndex = hotPosts.index(hotPosts.endIndex, offsetBy: offsetBy)
            if hotPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter)
            }
        } else if selectedFeedFilter == .recent {
            let thresholdIndex = recentPosts.index(recentPosts.endIndex, offsetBy: offsetBy)
            if recentPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter)
            }
        }
    }
    
    func paginatePosts(selectedFeedFilter: FeedFilter) {
        var url_to_use = ""
        
        // check if finished to prevent unnecessary network call
        if selectedFeedFilter == .top {
            url_to_use = topCurrentPage
            if finishedTop {
                return
            }
        } else if selectedFeedFilter == .hot {
            url_to_use = hotCurrentPage
            if finishedHot {
                return
            }
        } else if selectedFeedFilter == .recent {
            url_to_use = recentCurrentPage
            if finishedRecent {
                return
            }
        }
        
        NetworkManager.networkManager.request(route: url_to_use, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if selectedFeedFilter == .top {
                        self.topPosts.append(contentsOf: successResponse.results)
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        } else {
                            self.finishedTop = true
                        }
                    } else if selectedFeedFilter == .hot {
                        self.hotPosts.append(contentsOf: successResponse.results)
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        } else {
                            self.finishedHot = true
                        }
                    } else if selectedFeedFilter == .recent {
                        self.recentPosts.append(contentsOf: successResponse.results)
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        } else {
                            self.finishedRecent = true
                        }
                    }
                    self.InitalOpen = false
                }
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    func paginatePostsReset(selectedFeedFilter: FeedFilter) {
        var url_to_use = ""
        
        if selectedFeedFilter == .top {
            url_to_use = "posts/?sort=top"
            finishedTop = false
        } else if selectedFeedFilter == .hot {
            url_to_use = "posts/?sort=hot"
            finishedHot = false
        } else if selectedFeedFilter == .recent {
            url_to_use = "posts/?sort=new"
            finishedRecent = false
        }
        
        NetworkManager.networkManager.request(route: url_to_use, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if selectedFeedFilter == .top {
                        self.topPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        } else {
                            self.finishedTop = true
                        }
                    } else if selectedFeedFilter == .hot {
                        self.hotPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        } else {
                            self.finishedHot = true
                        }
                    } else if selectedFeedFilter == .recent {
                        self.topPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        } else {
                            self.finishedRecent = true
                        }
                    }
                }
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    // MARK: Read Post
    func readPost(postId: String, completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        NetworkManager.networkManager.request(route: "post/\(postId)", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    // replace the local post
                    if let index = self.hotPosts.firstIndex(where: {$0.id == postId}) {
                        self.hotPosts[index] = successResponse
                    }
                    if let index = self.recentPosts.firstIndex(where: {$0.id == postId}) {
                        self.recentPosts[index] = successResponse
                    }
                    if let index = self.topPosts.firstIndex(where: {$0.id == postId}) {
                        self.topPosts[index] = successResponse
                    }
                }
            }
        }
    }
    
    // MARK: Helper functions
    func deletePost(post: Post) {
        DispatchQueue.main.async {
            self.removePostLocally(post: post)
            self.removedPostType = "Post deleted!"
            self.removedPost = true
        }
    }
    
    func blockPost(post: Post) {
        DispatchQueue.main.async {
            self.removePostLocally(post: post)
            self.removedPostType = "User blocked!"
            self.removedPost = true
        }
    }
    
    func reportPost(post: Post) {
        DispatchQueue.main.async {
            self.removePostLocally(post: post)
            self.removedPostType = "Post reported!"
            self.removedPost = true
        }
    }
    
    // MARK: Helper function to delete posts in Feed
    func removePostLocally(post: Post) {
        DispatchQueue.main.async {
            withAnimation {
                print("DEBUG: \(post)")
                if let index = self.topPosts.firstIndex(of: post) {
                    self.topPosts.remove(at: index)
                    print("DEBUG: \(index)")
                }
                if let index = self.hotPosts.firstIndex(of: post) {
                    self.hotPosts.remove(at: index)
                    print("DEBUG: \(index)")
                }
                if let index = self.recentPosts.firstIndex(of: post) {
                    self.recentPosts.remove(at: index)
                    print("DEBUG: \(index)")
                }
            }
        }
    }
}
