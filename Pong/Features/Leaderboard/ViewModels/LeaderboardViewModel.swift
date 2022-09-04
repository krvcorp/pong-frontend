//
//  LeaderboardViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    
    @Published var nickname : String = ""
    
    func getLeaderboard(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/leaderboard/", method: .get, successType: [LeaderboardUser].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    var leaderboardList = successResponse
                    
                    var count : Int = 1
                    for _ in leaderboardList {
                        leaderboardList[count-1].place = String(count)
                        count += 1
                    }
                    DispatchQueue.main.async {
                        dataManager.leaderboardList = leaderboardList
                    }
                }
            }
        }
    }
    
    func updateNickname(nickname: String) {
        let parameters = Nickname.self(nickname: nickname)
        NetworkManager.networkManager.emptyRequest(route: "users/\(AuthManager.authManager.userId)/nickname/", method: .post, body: parameters) { successResponse, errorResponse in
            if let successResponse = successResponse {
                debugPrint(successResponse)
            }
        }
    }
    
    func getLoggedInUserInfo(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: User.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.totalKarma = successResponse.score
                    dataManager.commentKarma = successResponse.commentScore
                    dataManager.postKarma = successResponse.postScore
                    self.nickname = successResponse.nickname
                }
            }
        }
    }
}
