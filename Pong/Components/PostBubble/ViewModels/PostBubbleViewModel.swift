import Foundation

enum ActiveAlert {
    case delete, report, block
}

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    @Published var showConfirmation : Bool = false
    @Published var activeAlert: ActiveAlert = .delete
    
    @Published var savedPostConfirmation : Bool = false
    @Published var updateTrigger : Bool = false
    
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
                    self.updateTrigger.toggle()
                }
            }
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
            }
        }
    }
    
    func savePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.post = post
                    self.post.saved = true
                    self.savedPostConfirmation = true
                    self.updateTrigger.toggle()
                    dataManager.updatePostLocally(post: post)
                }
            }
        }
    }
    
    func unsavePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    print("DEBUG: Unsave success")
                    self.post.saved = false
                    self.updateTrigger.toggle()
                    dataManager.updatePostLocally(post: post)
                }
            }
        }
    }
    
    func deletePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Deleted post!")
            }
        }
    }
    
    func blockPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "User blocked!")
            }
        }
    }
    
    func reportPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Reported post!")
            }
        }
    }
    
    func startConversation(post: Post, dataManager: DataManager) {
        let parameters = CreateConversation.RequestPost(postId: post.id)
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: CreateConversation.Response.self) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Reported post!")
            }
        }
    }
}
