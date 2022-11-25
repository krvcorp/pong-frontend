import SwiftUI
import Foundation

class MessageViewModel: ObservableObject {
    @Published var conversation : Conversation = defaultConversation
    @Published var post : Post = defaultPost
    @Published var messageUpdateTrigger : Bool = false
    @Published var showBlockConfirmationView : Bool = false
    
    @Published var scrolledToBottom = false
    
    // MARK: SendMessage
    /// Sends a message to a conversation
    /// - Parameters:
    ///   - message: The message string
    /// - Returns: On completion calls getConversations and triggers scroll to bottom
    func sendMessage(message: String, completionHandler: @escaping (Bool) -> Void) {
        // send message
        NetworkManager.networkManager.emptyRequest(route: "messages/", method: .post, body: Message.Request(conversationId: conversation.id, message: message)) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    self.getConversation()
                    self.scrolledToBottom = false
                    completionHandler(true)
                }
            }
        }
    }
    
    // MARK: GetConversation
    /// Gets all conversations the user is a part of
    func getConversation() {
        NetworkManager.networkManager.request(route: "conversations/\(self.conversation.id)/", method: .get, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.conversation = successResponse
                self.messageUpdateTrigger.toggle()
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
                
            }
        }
    }
    
    // MARK: ReadConversation
    /// Marks the conversation as read
    func readConversation() {
        NetworkManager.networkManager.emptyRequest(route: "conversations/\(self.conversation.id)/read/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                self.getConversation()
                self.conversation.unreadCount = 0
            }
        }
    }
    
    // MARK: BlockUser
    /// Blocks the user of the conversation
    func blockUser(completionHandler: @escaping (Bool) -> Void) {
        NetworkManager.networkManager.emptyRequest(route: "conversations/\(self.conversation.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: blockUser success")
                completionHandler(true)
            }
            
            if errorResponse != nil {
                
            }
        }
    }
    
    // MARK: GetPost
    /// Gets the post for the conversation and opens the post object on completion
    func getPost(postId: String, completionHandler: @escaping (Post) -> Void) {
        if postId != "" {
            NetworkManager.networkManager.request(route: "posts/\(postId)/", method: .get, successType: Post.self) { successResponse, errorResponse in
                if successResponse != nil {
                    completionHandler(successResponse!)
                }
                
                if errorResponse != nil {
                    print("DEBUG: This post was probably deleted")
                }
            }
        }
    }
    
    // MARK: ReadPost
    /// Reads the post information
    func readPost(postId: String) {
        if postId != "" {
            NetworkManager.networkManager.request(route: "posts/\(postId)/", method: .get, successType: Post.self) { successResponse, errorResponse in
                if let successResponse = successResponse {
                    self.post = successResponse
                }
                
                if errorResponse != nil {
                    print("DEBUG: This post was probably deleted")
                }
            }
        }
    }
}
