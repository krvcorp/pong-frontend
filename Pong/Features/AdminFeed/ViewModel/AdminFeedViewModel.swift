import Foundation
import SwiftUI
import Alamofire

class AdminFeedViewModel: ObservableObject {
    @Published var flaggedPosts : [Post] = []

    // MARK: API
    func getPosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=flagged", method: .get, successType: [Post].self) { successResponse in
            self.flaggedPosts = successResponse
        }
    }
}
