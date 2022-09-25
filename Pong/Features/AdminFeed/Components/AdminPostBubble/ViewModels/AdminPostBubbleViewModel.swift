import Foundation

class AdminPostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    func applyTimeout(adminFeedVM: AdminFeedViewModel, time: Int) {
        let parameters = TimeoutModel.Request(time: time)
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/timeout/", method: .post, body: parameters) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let index = adminFeedVM.flaggedPosts.firstIndex(of: self.post) {
                    print("DEBUG: Removing post \(adminFeedVM.flaggedPosts)")
                    adminFeedVM.flaggedPosts.remove(at: index)
                    print("DEBUG: Removed post \(adminFeedVM.flaggedPosts)")
                }
            }
        }
    }
    
    
    func unflagPost(adminFeedVM: AdminFeedViewModel) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/approve/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let index = adminFeedVM.flaggedPosts.firstIndex(of: self.post) {
                    print("DEBUG: Removing post \(adminFeedVM.flaggedPosts)")
                    adminFeedVM.flaggedPosts.remove(at: index)
                    print("DEBUG: Removed post \(adminFeedVM.flaggedPosts)")
                }
            }
        }
    }
}
