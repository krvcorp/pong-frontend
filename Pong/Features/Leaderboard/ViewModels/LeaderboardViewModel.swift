//
//  LeaderboardViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var emojiIsFocused = false
    
    // MARK: GetLeaderboard
    func getLeaderboard(dataManager: DataManager) {
        dataManager.initLeaderboard()
    }
    
    // MARK: UpdateNickname
    func updateNickname(dataManager: DataManager, nickname: String, completion: @escaping (Bool) -> Void) {
        let parameters = Nickname.self(nickname: nickname)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/nickname/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                self.getLoggedInUserInfo(dataManager: dataManager)
                self.getLeaderboard(dataManager: dataManager)
                ToastManager.shared.toastDetected(message: "Nickname saved!")
                completion(true)
            }
            
            if errorResponse != nil {
                print("DEBUG: leaderboardVM.updateNickname error")
            }
        }
    }
    
    // MARK: GetLoggedInUserInfo
    func getLoggedInUserInfo(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: User.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.totalKarma = successResponse.score
                    dataManager.commentKarma = successResponse.commentScore
                    dataManager.postKarma = successResponse.postScore
                    dataManager.nickname = successResponse.nickname
                    dataManager.nicknameEmoji = successResponse.nicknameEmoji
                }
            }
        }
    }
    
    // MARK: SetEmoji
    func updateNickname(dataManager: DataManager, emoji: String, completion: @escaping (Bool) -> Void) {
        let parameters = Nickname.self(nickname: emoji)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/nickname_emoji/", method: .post, body: parameters) { successResponse, errorResponse in
            if successResponse != nil {
                self.getLoggedInUserInfo(dataManager: dataManager)
                self.getLeaderboard(dataManager: dataManager)
                ToastManager.shared.toastDetected(message: "Emoji saved!")
                completion(true)
            }
            
            if errorResponse != nil {
                print("DEBUG: leaderboardVM.updateNickname error")
            }
        }
    }
}
