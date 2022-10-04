import SwiftUI
import Foundation

class MessageViewModel: ObservableObject {
    @Published var conversation : Conversation = defaultConversation
//    @Published var messages : [Message] = []
    @Published var messageUpdateTrigger : Bool = false
    @Published var showBlockConfirmationView : Bool = false
    var timePassed = 0
    var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    @Published var scrolledToBottom = false
    
    // send a message
    func sendMessage(message: String) {
        // send message
        NetworkManager.networkManager.emptyRequest(route: "messages/", method: .post, body: Message.Request(conversationId: conversation.id, message: message)) { successResponse, errorResponse in
            if successResponse != nil {
                DispatchQueue.main.async {
                    print("DEBUG: sendMessage success")
                    self.getConversation()
                    self.scrolledToBottom = false
                }
            }
        }
    }
    
    func getConversation() {
        print("DEBUG: getConversation")
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
    
    func readConversation() {
        // send message
        NetworkManager.networkManager.emptyRequest(route: "conversations/\(self.conversation.id)/read/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: readMessage success")
                self.getConversation()
            }
        }
    }
    
    func blockUser(completionHandler: @escaping (Bool) -> Void) {
        // send message
        NetworkManager.networkManager.emptyRequest(route: "conversations/\(self.conversation.id)/block/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: blockUser success")
                self.getConversation()
            }
        }
    }
}
