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
        NetworkManager.networkManager.request(route: "leaderboard/", method: .get, successType: [TotalScore].self) { successResponse in
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
        // MARK: Non AF API

//
//        guard let token = DAKeychain.shared["token"] else { return } // Fetch
//
//        // GET params
//        let url_to_use: String = "\(API().root)leaderboard/"
//
//        // URL handler
//        guard let url = URL(string: url_to_use) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//
//        // Task handler. [weak self] prevents memory leaks
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//
//            guard let data = data, error == nil else { return }
//
//            // Convert fetch data into SWIFT JSON and store into variables
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                var leaderboardList = try decoder.decode([TotalScore].self, from: data)
//
//                var count : Int = 1
//                for _ in leaderboardList {
//                    leaderboardList[count-1].place = String(count)
//                    count += 1
//                }
//                DispatchQueue.main.async {
//                    self?.leaderboardList = leaderboardList
//                }
//
//            } catch {
//                print("DEBUG: \(error)")
//            }
//        }
//        // activates api call
//        task.resume()
    }
    
    func getLoggedInUserInfo() {
        print("DEBUG: leaderboardVM.getLoggedInUserInfo")
        NetworkManager.networkManager.request(route: "user/\(DAKeychain.shared["userId"])/", method: .get, successType: LoggedInUserInfoResponseBody.self) { successResponse in
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
        //MARK: Old API
//        guard let token = DAKeychain.shared["token"] else {
//            print("DEBUG: profileVM.getLoggedInUserInfo no token")
//            return
//        }
//
//        guard let userId = DAKeychain.shared["userId"] else {
//            print("DEBUG: profileVM.getLoggedInUserInfo no token")
//            return
//        }
//
//        guard let url = URL(string: "\(API().root)" + "user/" + userId + "/") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//
//            guard let data = data, error == nil else {
//                print("DEBUG: no data")
//                return
//            }
//
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            do {
//                let loggedInUserInfoResponse = try decoder.decode(LoggedInUserInfoResponseBody.self, from: data)
////                print("DEBUG: ProfileVM \(loggedInUserInfoResponse)")
//                DispatchQueue.main.async {
//                    self.totalKarma = loggedInUserInfoResponse.totalScore
//                    self.commentKarma = loggedInUserInfoResponse.commentScore
//                    self.postKarma = loggedInUserInfoResponse.postScore
//                    self.savedPosts = loggedInUserInfoResponse.savedPosts
//                    self.posts = loggedInUserInfoResponse.posts
//                    self.comments = loggedInUserInfoResponse.comments
//                }
//            } catch {
//                print("DEBUG: decode error \(error)")
//            }
//        }.resume()
//    }
    }
}
