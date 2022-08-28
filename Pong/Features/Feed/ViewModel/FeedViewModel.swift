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
    @Published var selectedTopFilter : TopFilter = .allTime
    
    @Published var finishedTop = false
    @Published var finishedHot = false
    @Published var finishedRecent = false
    
    //MARK: Pagination
    var topCurrentPage = "posts/?sort=top"
    
    var hotCurrentPage = "posts/?sort=hot"
    
    var recentCurrentPage = "posts/?sort=new"
    
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
    
    func paginatePosts(selectedFeedFilter: FeedFilter, dataManager: DataManager) {
        var url_to_use = ""
        
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
                        dataManager.topPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.topPosts.removingDuplicates()
                        dataManager.topPosts = uniqued
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        } else {
                            self.finishedTop = true
                        }
                    } else if selectedFeedFilter == .hot {
                        dataManager.hotPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.hotPosts.removingDuplicates()
                        dataManager.hotPosts = uniqued
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        } else {
                            self.finishedHot = true
                        }
                    } else if selectedFeedFilter == .recent {
                        dataManager.recentPosts.append(contentsOf: successResponse.results)
                        let uniqued = dataManager.recentPosts.removingDuplicates()
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
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    func paginatePostsReset(selectedFeedFilter: FeedFilter, dataManager: DataManager) {
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
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
}
