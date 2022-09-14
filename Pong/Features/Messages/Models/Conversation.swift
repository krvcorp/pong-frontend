//
//  Conversation.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/11/22.
//

import Foundation

struct Conversation: Hashable, Codable, Identifiable, Equatable {
    var id: String
    var messages: [Message]
    var re: String
    var read: Bool
    var timeSinceUpdated: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
