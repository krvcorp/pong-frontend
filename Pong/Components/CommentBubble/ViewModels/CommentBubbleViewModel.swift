import Foundation

class CommentBubbleViewModel: ObservableObject {
    @Published var comment : Comment = defaultComment
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
        }
        
        let parameters = CommentVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/vote/", method: .post, body: parameters, successType: CommentVoteModel.Response.self) { successResponse, errorResponse in
            // MARK: Success
            DispatchQueue.main.async {
                if successResponse != nil {
                    
                }
                if let errorResponse = errorResponse {
                    print("DEBUG: \(errorResponse)")
                    DispatchQueue.main.async {
                        self.comment.voteStatus = temp
                        dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't vote on comment")
                    }
                }
            }
        }
    }
    
    func deleteComment(comment: Comment, postVM: PostViewModel) {
        NetworkManager.networkManager.request(route: "comments/\(comment.id)/", method: .delete, successType: Post.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
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
                print("DEBUG: ")
            }
        }
    }
    
    func reportComment() {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/report/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                print("DEBUG: ")
            }
        }
    }
    
}
