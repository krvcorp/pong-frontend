//
//  LeaderboardViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
//    @Published var leaderboardList : [TotalScore] = []
//    @Published var totalKarma: Int = 0
//    @Published var commentKarma: Int = 0
//    @Published var postKarma: Int = 0
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var savedPosts: [Post] = []
    
    func getLeaderboard(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/leaderboard/", method: .get, successType: [TotalScore].self) { successResponse, errorResponse in
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
    
    func getLoggedInUserInfo(dataManager: DataManager) {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: LoggedInUserInfoResponseBody.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.totalKarma = successResponse.totalScore
                    dataManager.commentKarma = successResponse.commentScore
                    dataManager.postKarma = successResponse.postScore
                }
            }
        }
    }
}
