//
//  AppState.swift
//  Pong
//
//  Created by Khoi Nguyen on 10/10/22.
//

import Foundation

class AppState: ObservableObject {
    
    static let shared = AppState()
    
    @Published var postToNavigateTo : String?
    @Published var post : Post = defaultPost
    
    @Published var leaderboard : Bool?
    
    @Published var conversationToNavigateTo : String?
    @Published var conversation : Conversation = defaultConversation
    
    // MARK: ReadPost
    /// Get a post based on the user tapping on a notification
    func readPost(url : String, completion: @escaping (Bool) -> Void) {
        print("DEBUG: AppState.readPost \(url)")
        NetworkManager.networkManager.request(route: "posts/\(url)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    self.post = successResponse
                    completion(true)
                }
                
                if errorResponse != nil {
                    print("DEBUG: error")
                    self.post = defaultPost
                }
            }
        }
    }
    
    // MARK: ReadConversation
    /// Get a conversation based on the user tapping on a notification
    func readConversation(url : String) {
        print("DEBUG: appState.readConversation \(url)")
        NetworkManager.networkManager.request(route: "conversations/\(url)/", method: .get, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.conversation = successResponse
            }
            
            if errorResponse != nil {
                print("DEBUG: error")
            }
        }
    }
}
