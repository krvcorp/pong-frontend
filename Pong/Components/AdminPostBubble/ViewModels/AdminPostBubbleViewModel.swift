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
    
    
    func unflagPost() {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/approve/", method: .post, successType: Post.self) { successResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
}
