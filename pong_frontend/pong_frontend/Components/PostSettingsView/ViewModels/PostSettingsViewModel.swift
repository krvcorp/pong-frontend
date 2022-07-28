//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation
import Alamofire

@MainActor class PostSettingsViewModel: ObservableObject {
    
    @Published var post: Post = defaultPost
    @Published var showPostSettingsView : Bool = false
    
    
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
}
