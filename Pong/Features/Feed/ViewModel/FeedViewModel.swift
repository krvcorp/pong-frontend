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
    
    //MARK: Pagination
    var topCurrentPage = "posts/?sort=top"
    
    var hotCurrentPage = "posts/?sort=hot"
    
    var recentCurrentPage = "posts/?sort=old"
    
    func paginatePosts(selectedFeedFilter: FeedFilter) {
        var url_to_use = ""
        
        if selectedFeedFilter == .top {
            url_to_use = topCurrentPage
            if finishedTop {
                print("DEBUG: NO TOP LEFT")
                return
            }
        } else if selectedFeedFilter == .hot {
            url_to_use = hotCurrentPage
            if finishedHot {
                print("DEBUG: NO HOT LEFT")
                return
            }
        } else if selectedFeedFilter == .recent {
            url_to_use = recentCurrentPage
            if finishedRecent {
                print("DEBUG: NO RECENT LEFT")
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
            url_to_use = "posts/?sort=recent"
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
}
