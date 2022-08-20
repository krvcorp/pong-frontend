import Foundation

class AdminPostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    
    func applyTimeoutDay() {
        let time = 24 * 60
        let parameters = TimeoutModel.Request(time: time)
        NetworkManager.networkManager.request(route: "posts/\(post.id)/timeout/", method: .post, body: parameters, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: Timeout applied")
            }
        }
    }
    
    func applyTimeoutWeek() {
        let time = 24 * 60 * 7
        let parameters = TimeoutModel.Request(time: time)
        NetworkManager.networkManager.request(route: "posts/\(post.id)/timeout/", method: .post, body: parameters, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: Timeout applied")
            }
        }
    }
    
    
    func unflagPost(adminFeedVM: AdminFeedViewModel) {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/approve/", method: .post, successType: Post.self) { successResponse in
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