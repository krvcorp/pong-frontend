import Foundation
import SwiftUI
import Alamofire

enum AdminFilter: String, CaseIterable, Identifiable {
    case posts, comments
    var id: Self { self }
    
    var title: String {
        switch self {
        case .posts: return "Posts"
        case .comments: return "Comments"
        }
    }
    
    var imageName: String {
        switch self {
        case .posts: return "square.grid.2x2"
        case .comments: return "arrowshape.turn.up.left.2"
        }
    }
    
    var filledImageName: String {
        switch self {
        case .posts: return "square.grid.2x2.fill"
        case .comments: return "arrowshape.turn.up.left.2.fill"
        }
    }
}

class AdminFeedViewModel: ObservableObject {
    @Published var flaggedPosts : [Post] = []
    @Published var selectedFilter : AdminFilter = .posts

    func getPosts() {
        print("DEBUG: get flagged posts")
        NetworkManager.networkManager.request(route: "posts/?sort=flagged", method: .get, successType: [Post].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                print("DEBUG: \(successResponse)")
                self.flaggedPosts = successResponse
            }
        }
    }
}
