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
    @Published var scrollToTop : Bool = false
    
    @Published var openConversationsDetected: Bool = false
    @Published var openConversationDetected: Bool = false
    @Published var openConversation: Conversation = defaultConversation

    
    // MARK: NewPost
    func newPost() {
        DispatchQueue.main.async {
            self.scrollToTop.toggle()
            self.newPostDetected.toggle()
        }
    }
    
    func scrollToTopTrigger() {
        DispatchQueue.main.async {
            self.scrollToTop.toggle()
        }
    }
}
