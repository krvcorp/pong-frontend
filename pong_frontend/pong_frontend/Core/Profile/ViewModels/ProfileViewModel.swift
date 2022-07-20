//
//  ProfileViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/9/22.
//

import Foundation

class ProfileViewModel: ObservableObject {    
    @Published var totalKarma: Int = 0
    @Published var commentKarma: Int = 0
    @Published var postKarma: Int = 0
    
    func getLoggedInUserInfo(id: String) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        guard let url = URL(string: "\(API().root)" + "user/" + id + "/") else {
            return
        }
        
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let loggedInUserInfoResponse = try? decoder.decode(LoggedInUserInfoResponseBody.self, from: data) else {
                return
            }
            
            print("\(loggedInUserInfoResponse)")
            
            print("totalKarma: \(loggedInUserInfoResponse.totalKarma)")
            
            self.totalKarma = loggedInUserInfoResponse.totalKarma
            self.commentKarma = loggedInUserInfoResponse.commentKarma
            self.postKarma = loggedInUserInfoResponse.postKarma
            
        }.resume()
    }
}
