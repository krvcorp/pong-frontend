//
//  LeaderboardViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboardList : [TotalScore] = [defaultTotalScore]
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var savedPosts: [Post] = []
    
    func getLeaderboard() {
        print("DEBUG: leaderboardVM.getLeaderboard")
        NetworkManager.networkManager.request(route: "users/leaderboard/", method: .get, successType: [TotalScore].self) { successResponse in
            DispatchQueue.main.async {
                var leaderboardList = successResponse
                
                var count : Int = 1
                for _ in leaderboardList {
                    leaderboardList[count-1].place = String(count)
                    count += 1
                }
                DispatchQueue.main.async {
                    self.leaderboardList = leaderboardList
                }
            }
        }
    }
    
    func getLoggedInUserInfo() {
        print("DEBUG: leaderboardVM.getLoggedInUserInfo")
        
        NetworkManager.networkManager.request(route: "users/", method: .get, successType: LoggedInUserInfoResponseBody.self) { successResponse in
            DispatchQueue.main.async {
                self.totalKarma = successResponse.totalScore
                self.commentKarma = successResponse.commentScore
                self.postKarma = successResponse.postScore
                self.savedPosts = successResponse.savedPosts
                self.posts = successResponse.posts
                self.comments = successResponse.comments
                print("DEBUG: leaderboardVM.getLoggedInUserInfo total karma \(self.totalKarma)")
            }
        }
    }
}
