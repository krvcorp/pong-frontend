import Foundation

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    @Published var showDeleteConfirmationView : Bool = false
    
    func postVote(direction: Int, post: Post) -> Void {
        var voteToSend = 0
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
            // MARK: Success
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.voteStatus = successResponse.voteStatus
                }
            }
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    func deletePost(post: Post) {
        NetworkManager.networkManager.request(route: "posts/\(post.id)/", method: .delete, successType: Post.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: postBubbleVM.deletePost")
                
            }
        }
    }
    
    func savePost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    print("DEBUG: postBubbleVM.savePost")
                    self.post = post
                    self.post.saved = true
                }
            }
        }
    }
    
    func unsavePost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    print("DEBUG: postBubbleVM.unsavePost")
                    self.post = post
                    self.post.saved = false
                }
            }
        }
    }
    
    func blockPost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func reportPost(post: Post) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
}
