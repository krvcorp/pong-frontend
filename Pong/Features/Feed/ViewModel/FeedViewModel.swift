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
}

// MARK: Swipe Direction
enum SwipeDirection{
    case up
    case down
    case none
}

class FeedViewModel: ObservableObject {
    @Published var selectedFeedFilter : FeedFilter = .hot
    @Published var school = "Boston University"
    @Published var isShowingNewPostSheet = false
    @Published var InitalOpen : Bool = true
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    // MARK: SwipeHiddenHeader
    // MARK: View Properties
    @Published var headerHeight: CGFloat = 0
    @Published var headerOffset: CGFloat = 0
    @Published var lastHeaderOffset: CGFloat = 0
    @Published var headerDirection: SwipeDirection = .none
    // MARK: Shift Offset Means The Value From Where It Shifted From Up/Down
    @Published var headerShiftOffset: CGFloat = 0
    
    // MARK: DynamicTabIndicator
    // MARK: View Properties
    @Published var tabviewOffset: CGFloat = 0
    @Published var tabviewIsTapped: Bool = false
    
    // MARK: Tab Offset
    func tabOffset(size: CGSize,padding: CGFloat)->CGFloat{
        return (-tabviewOffset / size.width) * ((size.width - padding) / CGFloat(FeedFilter.allCases.count))
    }
    
    // MARK: Tab Index
    func indexOf(tab: FeedFilter)->Int{
        if tab == .top {
            return 0
        } else if tab == .hot {
            return 1
        } else if tab == .recent {
            return 2
        } else {
            return 1
        }
    }
    
    // MARK: API SHIT
    func getPosts(selectedFeedFilter : FeedFilter) {
        let url_to_use: String
        
        if selectedFeedFilter == .top {
            url_to_use = "post/?sort=top"
        } else if selectedFeedFilter == .hot {
            url_to_use = "post/?sort=hot"
        } else {
            url_to_use = "post/?sort=new"
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
