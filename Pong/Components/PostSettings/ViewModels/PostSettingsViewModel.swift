//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation
import Alamofire

class PostSettingsViewModel: ObservableObject {
    @Published var post: Post = defaultPost
    @Published var showPostSettingsView : Bool = false
    @Published var showDeleteConfirmationView : Bool = false
    @Published var showReportConfirmationView : Bool = false
    
    func reportPostAlamofire() {
        let parameters: [String: Any] = [
            "post_id": post.id
        ]
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Authorization": "Token \(DAKeychain.shared["token"]!)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        AF.request("\(API().root)postreport/", method: method, parameters: parameters, headers: headers).response { response in
            debugPrint(response)
        }
    }

    func savePostAlamofire() {
        let parameters: [String: Any] = [
            "post_id": post.id
        ]
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Authorization": "Token \(DAKeychain.shared["token"]!)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        AF.request("\(API().root)postsave/", method: method, parameters: parameters, headers: headers).response { response in
            debugPrint(response)
        }
    }

    func blockUserAlamofire() {
        let parameters: [String: Any] = [
            "post_id": post.id
        ]
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Authorization": "Token \(DAKeychain.shared["token"]!)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        AF.request("\(API().root)block/", method: method, parameters: parameters, headers: headers).response { response in
            debugPrint(response)
        }
    }
    
    func deletePost() {
        print("DEBUG: PostSettingsVM.deletePost \(post.id)")
        
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)post/\(post.id)/") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.showDeleteConfirmationView = false
            }
        }.resume()
    }
}
