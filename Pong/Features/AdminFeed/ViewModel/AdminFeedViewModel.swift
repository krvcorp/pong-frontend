import Foundation
import SwiftUI
import Alamofire

class AdminFeedViewModel: ObservableObject {
    @Published var flaggedPosts : [Post] = []

    func getPosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=flagged", method: .get, successType: [Post].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.flaggedPosts = successResponse
            }
        }
    }
}
