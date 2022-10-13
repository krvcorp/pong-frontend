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
    
    func readPost(url : String) {
        NetworkManager.networkManager.request(route: "posts/\(url)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    print("DEBUG: \(successResponse)")
                    self.post = successResponse
                }
            }
            
            if errorResponse != nil {
                print("DEBUG: error")
            }
        }
    }
    
    func readConversation(url : String) {
        print("DEBUG: appState.readConversation \(url)")
        NetworkManager.networkManager.request(route: "conversations/\(url)/", method: .get, successType: Conversation.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                print("DEBUG: appState.readConvesation success")
                self.conversation = successResponse
            }
            
            if let errorResponse = errorResponse {
                print("DEBUG: \(errorResponse)")
                
            }
        }
    }
}
