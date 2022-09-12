//
//  MessageViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/11/22.
//

import MessageKit
import SwiftUI
import Foundation

//public protocol MessageType {
//
//    /// The sender of the message.
//    var sender: SenderType { get }
//
//    /// The unique identifier for the message.
//    var messageId: String { get }
//
//    /// The date the message was sent.
//    var sentDate: Date { get }
//
//    /// The kind of message and its underlying kind.
//    var kind: MessageKind { get }
//
//}

class MessageViewModel: ObservableObject {
    @Published var conversation : Conversation = defaultConversation
    @Published var messages : [Message] = []
    @Published var messageKitMessages : [MessageType] = []
    
    // create a function that takes in a [Message] and returns a [MessageType]
    func ourMessageAPIToMessageKitAPI(messages : [Message]) {
        var returnArray : [MessageType] = []
        for message in messages {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: message.createdAt)!
            
            let convertedMessage : MessageType = MockMessage(text: message.message,
                                                             user: MockUser(senderId: message.userOwned ? "1" : "0", displayName: message.userOwned ? "Me" : "Anon"),
                                                             messageId: message.id,
                                                             date: date)
            returnArray.append(convertedMessage)
        }
        self.messageKitMessages = returnArray
    }
    
    // send a message
    func sendMessage(message: String) {
        // send message
        print("DEBUG: sendMessage")
        print("DEBUG: \(conversation.id)")
        print("DEBUG: \(message)")
        NetworkManager.networkManager.emptyRequest(route: "messages/", method: .post, body: Message.Request(conversationId: conversation.id, message: message)) { successResponse, errorResponse in
            if successResponse != nil {
                print("DEBUG: sendMEssage success")
            }
        }
        // if success, poll this conversation
        // call convert
        
    }
}
