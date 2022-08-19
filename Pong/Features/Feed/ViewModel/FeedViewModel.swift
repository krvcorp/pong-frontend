//
//  FeedViewModel.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
import Foundation
import SwiftUI
import Alamofire

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
    @Published var isShowingNewPostSheet = false
    @Published var InitalOpen : Bool = true
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    @Published var selectedTopFilter : TopFilter = .allTime
    
    // MARK: API SHIT
    func getPosts(selectedFeedFilter : FeedFilter) {
        let url_to_use: String
        
        if selectedFeedFilter == .top {
            url_to_use = "posts/?sort=top"
        } else if selectedFeedFilter == .hot {
            url_to_use = "posts/?sort=hot"
        } else {
            url_to_use = "posts/?sort=new"
        }
        
        NetworkManager.networkManager.request(route: url_to_use, method: .get, successType: [Post].self) { successResponse in
            if selectedFeedFilter == .top {
                self.topPosts = successResponse
            } else if selectedFeedFilter == .hot {
                self.hotPosts = successResponse
            } else if selectedFeedFilter == .recent {
                self.recentPosts = successResponse
            }
        }
        
        self.InitalOpen = false
    }

    
    // MARK: Read Post
    func readPost(postId: String, completion: @escaping (Result<Post, AuthenticationError>) -> Void) {
        NetworkManager.networkManager.request(route: "post/\(postId)", method: .get, successType: Post.self) { successResponse in
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
