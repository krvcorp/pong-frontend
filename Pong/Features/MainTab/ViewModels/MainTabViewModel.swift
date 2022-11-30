//
//  MainTabViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/5/22.
//
import Foundation
import Combine

class MainTabViewModel: ObservableObject {
    
    static let shared = MainTabViewModel()
    
    @Published var newPostDetected: Bool = false
    
    @Published var openConversationsDetected: Bool = false
    @Published var openConversationDetected: Bool = false
    @Published var openConversation: Conversation = defaultConversation
    
    @Published var scrollToTop : Bool = false

    func newPost() {
        DispatchQueue.main.async {
            self.newPostDetected.toggle()
        }
    }
}
