import Foundation

class CommentBubbleViewModel: ObservableObject {
    @Published var comment : Comment = defaultComment
    @Published var commentUpdateTrigger : Bool = false
    @Published var showDeleteConfirmationView : Bool = false
    
    // MARK: CommentVote
    func commentVote(direction: Int, dataManager: DataManager) -> Void {
        var voteToSend = 0
        let temp = self.comment.voteStatus
        
        if direction == comment.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        DispatchQueue.main.async {
            self.comment.voteStatus = voteToSend
            self.commentUpdateTrigger.toggle()
        }
        
        let parameters = CommentVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/vote/", method: .post, body: parameters, successType: CommentVoteModel.Response.self) { successResponse, errorResponse in
            // top comment works regarding no internet kinda but replies don't get corrected
//            DispatchQueue.main.async {
                if successResponse != nil {
                    
                }
                
                // MARK: self.commentUpdateTrigger IS NOT TRIGGERING onChange??????????????
                if errorResponse != nil {
                    self.comment.voteStatus = temp
                    self.commentUpdateTrigger.toggle()
                    dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't vote on comment")
                }
//            }
        }
    }
    
    func deleteComment(comment: Comment, postVM: PostViewModel) {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/", method: .delete, successType: Post.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                self.commentUpdateTrigger.toggle()
                print("DEBUG: ")
            }
        }
    }
    
    func saveComment() {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/save/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
    func blockComment() {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/block/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                self.commentUpdateTrigger.toggle()
                print("DEBUG: ")
            }
        }
    }
    
    func reportComment() {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/report/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                self.commentUpdateTrigger.toggle()
                print("DEBUG: ")
            }
        }
    }
}
