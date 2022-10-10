import Foundation

class ProfileCommentBubbleViewModel: ObservableObject {
    @Published var comment : ProfileComment = defaultProfileComment
    @Published var showDeleteConfirmationView : Bool = false
    @Published var parentPost : Post = defaultPost
    @Published var commentUpdateTrigger : Bool = false
    
    func deleteComment(dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(self.comment.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removeCommentLocally(commentId: self.comment.id, message: "Comment deleted!")
            }
        }
    }
    
    func getParentPost() {
        NetworkManager.networkManager.request(route: "posts/\(self.comment.rePostId)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.parentPost = successResponse!
            }
        }
    }
    
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
            if successResponse != nil {
                debugPrint("Voting on comment worked")
            }
            if errorResponse != nil {
                self.comment.voteStatus = temp
                self.commentUpdateTrigger.toggle()
                dataManager.errorDetected(message: "Something went wrong!", subMessage: "Couldn't vote on comment")
            }
        }
    }
}
