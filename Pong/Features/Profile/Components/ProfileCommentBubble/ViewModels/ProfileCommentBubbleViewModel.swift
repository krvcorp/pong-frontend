import Foundation

class ProfileCommentBubbleViewModel: ObservableObject {
    @Published var comment : ProfileComment = defaultProfileComment
    @Published var showDeleteConfirmationView : Bool = false
    @Published var parentPost : Post = defaultPost
    
    func deleteComment(comment: ProfileComment, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removeCommentLocally(commentId: comment.id, message: "Comment deleted!")
            }
        }
    }
    
    func getParentPost(comment: ProfileComment) {
        NetworkManager.networkManager.request(route: "posts/\(comment.rePostId)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.parentPost = successResponse!
            }
        }
    }
}
