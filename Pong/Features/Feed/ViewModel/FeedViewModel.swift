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

// MARK: FeedFilter
/// Feed filter is just top, hot, or recent
enum FeedFilter: String, CaseIterable, Identifiable {
    case top, hot, recent
    var id: Self { self }
    
    var title: String {
        switch self {
        case .top: return "TOP"
        case .hot: return "HOT"
        case .recent: return "NEW"
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

// MARK: Timer
/// Timer for polling of conversations / messages
var timePassed = 0
var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

// MARK: TopFilter
enum TopFilter: String, CaseIterable, Identifiable, Equatable {
    case all, month, week
    var id: Self { self }
    
    var title: String {
        switch self {
        case .all: return "All Time"
        case .month: return "Month"
        case .week: return "Week"
        }
    }
}

// MARK: FeedViewModel
class FeedViewModel: ObservableObject {
    @Published var selectedFeedFilter : FeedFilter = .hot
    @Published var school = "Boston University"
    @Published var InitalOpen : Bool = true
    @Published var selectedTopFilter : TopFilter = .all
    
    @Published var finishedTop = false
    @Published var finishedHot = false
    @Published var finishedRecent = false
    
    //MARK: Pagination
    var topCurrentPage = "posts/?sort=top&range=all"
    
    var hotCurrentPage = "posts/?sort=hot"
    
    var recentCurrentPage = "posts/?sort=new"
    
    // MARK: PaginatePostsIfNeeded
    /// Checks if the list has scrolled to a particular offset
    func paginatePostsIfNeeded(post: Post, selectedFeedFilter: FeedFilter, dataManager: DataManager) {
        let offsetBy = -15

        if selectedFeedFilter == .top {
            let thresholdIndex = dataManager.topPosts.index(dataManager.topPosts.endIndex, offsetBy: offsetBy)
            if dataManager.topPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter, dataManager: dataManager)
            }
        } else if selectedFeedFilter == .hot {
            let thresholdIndex = dataManager.hotPosts.index(dataManager.hotPosts.endIndex, offsetBy: offsetBy)
            if dataManager.hotPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter, dataManager: dataManager)
            }
        } else if selectedFeedFilter == .recent {
            let thresholdIndex = dataManager.recentPosts.index(dataManager.recentPosts.endIndex, offsetBy: offsetBy)
            if dataManager.recentPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(selectedFeedFilter: selectedFeedFilter, dataManager: dataManager)
            }
        }
    }
    
    // MARK: PaginatePosts
    /// Gets the next page of posts based on the filter
    func paginatePosts(selectedFeedFilter: FeedFilter, dataManager: DataManager) {
        
        var urlToUse = ""
        
        if selectedFeedFilter == .top {
            urlToUse = topCurrentPage
            if finishedTop {
                return
            }
        } else if selectedFeedFilter == .hot {
            urlToUse = hotCurrentPage
            if finishedHot {
                return
            }
        } else if selectedFeedFilter == .recent {
            urlToUse = recentCurrentPage
            if finishedRecent {
                return
            }
        }
        
        NetworkManager.networkManager.request(route: urlToUse, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if selectedFeedFilter == .top {
                        dataManager.topPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.topPosts.uniqued()
                        dataManager.topPosts = uniqued
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        } else {
                            self.finishedTop = true
                        }
                    } else if selectedFeedFilter == .hot {
                        dataManager.hotPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.hotPosts.uniqued()
                        dataManager.hotPosts = uniqued
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        } else {
                            self.finishedHot = true
                        }
                    } else if selectedFeedFilter == .recent {
                        dataManager.recentPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.recentPosts.uniqued()
                        dataManager.recentPosts = uniqued
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        } else {
                            self.finishedRecent = true
                        }
                    }
                    self.InitalOpen = false
                }
            }
        }
    }
    
    // MARK: PaginatePostsReset
    /// Gets the first page of a particular filter and replaces whatever is stored
    func paginatePostsReset(selectedFeedFilter: FeedFilter, dataManager: DataManager) {
        var url_to_use = ""
        
        if selectedFeedFilter == .top {
            url_to_use = "posts/?sort=top" + checkTopFilter(filter: selectedTopFilter)
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
                        dataManager.topPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        } else {
                            self.finishedTop = true
                        }
                    } else if selectedFeedFilter == .hot {
                        dataManager.hotPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        } else {
                            self.finishedHot = true
                        }
                    } else if selectedFeedFilter == .recent {
                        dataManager.recentPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        } else {
                            self.finishedRecent = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: CheckTopFilter
    /// not sure what this does right now
    func checkTopFilter(filter : TopFilter) -> String {
        if filter == .all {
            return "&range=all"
        } else if filter == .month {
            return "&range=month"
        } else if filter == .week {
            return "&range=week"
        } else {
            return "neverHit"
        }
    }
    
    // MARK: GetConversations
    /// Gets the latest conversations
    func getConversations(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: "conversations/", method: .get, successType: [Conversation].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if dataManager.conversations != successResponse {
                        dataManager.conversations = successResponse
                    }
                }
            }
        }
    }
}
