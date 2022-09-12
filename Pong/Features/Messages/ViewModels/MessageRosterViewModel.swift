//
//  MessageRosterViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/11/22.
//

import MessageKit
import SwiftUI
import Foundation

class MessageRosterViewModel: ObservableObject {
//    @Published var conversations = []
    @Published var conversations : [Conversation] = [Conversation(id: "1",
                                                                  messages: [Message(id: "3", message: "Fuck you", createdAt: "2016-04-14T10:44:00+0000", userOwned: true)],
                                                                  re: "Brattle street when jefes moves in",
                                                                  read: true),
                                                     Conversation(id: "2",
                                                                  messages: [Message(id: "4", message: "What if you didn't", createdAt: "2016-04-14T10:44:00+0000", userOwned: false)],
                                                                  re: "What if I 👉👈 got the HSA bigger bed",
                                                                  read: false)]
    @Published var timePassed = 0
    @Published var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @Published var insideMessageView = false
    
    // MARK: Polling here
    func getConversations() {
        NetworkManager.networkManager.request(route: "conversation/conversations", method: .get, successType: [Conversation].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.conversations = successResponse
                }
            }
        }
    }
}

