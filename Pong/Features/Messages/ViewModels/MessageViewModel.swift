//
//  MessageViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/11/22.
//

import MessageKit
import SwiftUI
import Foundation

class MessageViewModel: ObservableObject {
    @Published var conversation : Conversation = defaultConversation
    @Published var messages : [Message] = []
    @Published var messageKitMessages : [MessageType] = []
    @Published var messageUpdateTrigger : Bool = true
    var timePassed = 0
    var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    // create a function that takes in a [Message] and returns a [MessageType]
    func ourMessageAPIToMessageKitAPI(messages : [Message]) {
        var returnArray : [MessageType] = []
        for message in messages {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            let date = dateFormatter.date(from: message.createdAt)!
            
            let convertedMessage : MessageType = MockMessage(text: message.message,
                                                             user: MockUser(senderId: message.userOwned ? "1" : "0", displayName: message.userOwned ? "Me" : "Anon"),
                                                             messageId: message.id,
                                                             date: date)
            returnArray.append(convertedMessage)
        }
        
        if self.messages != messages {
            self.messageKitMessages = returnArray
        }
    }
    
    // send a message
    func sendMessage(message: String) {
        // send message
        NetworkManager.networkManager.emptyRequest(route: "messages/", method: .post, body: Message.Request(conversationId: conversation.id, message: message)) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: sendMEssage success")
                self.getConversation()
            }
        }
    }
    
    func getConversation() {
        NetworkManager.networkManager.request(route: "conversations/\(self.conversation.id)/", method: .get, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                if self.conversation != successResponse {
                    self.conversation = successResponse
                    self.messageUpdateTrigger.toggle()
                }
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
                
            }
        }
    }
}
