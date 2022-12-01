import Foundation
import SwiftUI

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
    
    
    // MARK: PostVote
    func postVote(direction: Int, post: Post, dataManager: DataManager) -> Void {
        
//        Math for vote calculation
        var voteToSend = 0
        let temp = self.post.voteStatus
        
        if direction == post.voteStatus {
            voteToSend = 0
        } else {
            voteToSend = direction
        }
        
        
        DispatchQueue.main.async {
            self.post = post
            self.post.voteStatus = voteToSend
            self.updateTrigger.toggle()
        }
        
        let parameters = PostVoteModel.Request(vote: voteToSend)
        
        NetworkManager.networkManager.request(route: "posts/\(post.id)/vote/", method: .post, body: parameters, successType: PostVoteModel.Response.self) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    dataManager.updatePostLocally(post: self.post)
                }
            }
            
            if errorResponse != nil {
                DispatchQueue.main.async {
                    self.post.voteStatus = temp
                    self.updateTrigger.toggle()
                }
            }
        }
    }
    
    // MARK: SavePost
    func savePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            withAnimation {
                self.post = post
                self.post.saved = true
                self.updateTrigger.toggle()
                self.savedPostConfirmation = true
            }
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    withAnimation {
                        dataManager.updatePostLocally(post: self.post)
                        self.updateTrigger.toggle()
                    }
                }
            } else if errorResponse != nil {
                self.post = post
                self.post.saved = false
                self.updateTrigger.toggle()
            }
        }
    }
    
    // MARK: UnsavePost
    func unsavePost(post: Post, dataManager: DataManager) {
        DispatchQueue.main.async {
            withAnimation {
                self.post = post
                self.post.saved = false
                self.updateTrigger.toggle()
            }
        }
        
        if let index = dataManager.profileSavedPosts.firstIndex(where: {$0.id == post.id}) {
            dataManager.profileSavedPosts.remove(at: index)
        }
        
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/save/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    dataManager.updatePostLocally(post: self.post)
                    self.updateTrigger.toggle()
                }
            } else if errorResponse != nil {
                self.post = post
                self.post.saved = true
                self.updateTrigger.toggle()
            }
        }
    }
    
    // MARK: DeletePost
    func deletePost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/", method: .delete) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Deleted post!")
            }
        }
    }
    
    // MARK: BlockPost
    func blockPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "User blocked!")
            }
        }
    }
    
    // MARK: ReportPost
    func reportPost(post: Post, dataManager: DataManager) {
        NetworkManager.networkManager.emptyRequest(route: "posts/\(post.id)/report/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                dataManager.removePostLocally(post: post, message: "Reported post!")
            }
        }
    }
    
    // MARK: StartConversation
    func startConversation(post: Post, dataManager: DataManager, completion: @escaping (Conversation) -> Void) {
        let parameters = CreateConversation.RequestPost(postId: post.id)
        
        NetworkManager.networkManager.request(route: "conversations/", method: .post, body: parameters, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                completion(successResponse)
            }
        }
    }
}
