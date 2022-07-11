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
        guard let url = URL(string: "http://127.0.0.1:8005/api/" + "user/" + id + "/") else {
            return
        }
        
        print("\(url)")
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token 50af864e998ac9340d775b9547e5577edd7497ee", forHTTPHeaderField: "Authorization")
        
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
            
            print("totalKarma: \(loggedInUserInfoResponse.total_karma)")
            
            self.totalKarma = loggedInUserInfoResponse.total_karma
            self.commentKarma = loggedInUserInfoResponse.comment_karma
            self.postKarma = loggedInUserInfoResponse.post_karma
            
        }.resume()
    }
}
