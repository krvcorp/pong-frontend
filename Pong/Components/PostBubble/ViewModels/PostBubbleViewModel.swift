import Foundation

enum ActiveAlert {
    case delete, report, block
}

class PostBubbleViewModel: ObservableObject {
    @Published var post : Post = defaultPost
    
    @Published var showConfirmation : Bool = false
    @Published var activeAlert: ActiveAlert = .delete
    
    @Published var savedPostConfirmation : Bool = false
    // this triggers a .onChange in the view file to bind the values between self.post and a binding post var
    @Published var updateTrigger : Bool = false
    
    func postVote(direction: Int, post: Post, dataManager: DataManager) -> Void {
        var voteToSend = 0
        let temp = self.post.voteStatus
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        DispatchQueue.main.async {
            self.post = post
            self.post.voteStatus = voteToSend
            self.updateTrigger.toggle()
        }
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
            // MARK: Success
            if successResponse != nil {
                
            }
            
            if errorResponse != nil {
                print("DEBUG: IN HERE")
                DispatchQueue.main.async {
                    self.post.voteStatus = temp
                    self.updateTrigger.toggle()
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't vote on post")
                    self.updateTrigger.toggle()
                }
            }
        }
    }
    
    func savePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            self.post = post
            self.post.saved = true
            self.updateTrigger.toggle()
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.savedPostConfirmation = true
                    dataManager.updatePostLocally(post: post)
                    self.updateTrigger.toggle()
                }
            } else if errorResponse != nil {
                self.post = post
                self.post.saved = false
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't save post")
                self.updateTrigger.toggle()
            }
        }
    }
    
    func unsavePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            self.post.saved = false
            self.updateTrigger.toggle()
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    dataManager.updatePostLocally(post: post)
                    self.updateTrigger.toggle()
                }
            } else if errorResponse != nil {
                self.post = post
                self.post.saved = true
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't unsave post")
                self.updateTrigger.toggle()
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
    
    func startConversation(post: Post, dataManager: DataManager, mainTabVM: MainTabViewModel) {
        let parameters = CreateConversation.RequestPost(postId: post.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: \(successResponse!)")
                mainTabVM.openDMs(conversation: successResponse!)
            }
        }
    }
}
