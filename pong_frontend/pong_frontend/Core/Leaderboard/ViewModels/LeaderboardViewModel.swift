//
//  LeaderboardViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboardList : [TotalScore] = []
    
    func getLeaderboard() {
        print("DEBUG: leaderboardBM getLeaderboard")

        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        // GET params
        let url_to_use: String = "\(API().root)user/?sort=leaderboard"
        
        // URL handler
        
        guard let url = URL(string: url_to_use) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // Task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // Convert fetch data into SWIFT JSON and store into variables
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let leaderboardList = try decoder.decode([TotalScore].self, from: data)
                DispatchQueue.main.async {
                    self?.leaderboardList = leaderboardList
                }
            } catch {
                print("DEBUG: \(error)")
            }
        }
        // activates api call
        task.resume()
    }
}