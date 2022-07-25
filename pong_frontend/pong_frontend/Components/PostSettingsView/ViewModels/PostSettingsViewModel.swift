//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation

@MainActor class PostSettingsViewModel: ObservableObject {
    
    @Published var post: Post = defaultPost
    @Published var showPostSettingsView : Bool = false
    
    func reportPost(postId: String) {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)postreport/") else {
            return
        }
        
        let body = CreatePostReportRequestBody(postId: postId)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let commentResponse = try? decoder.decode(Comment.self, from: data) else { return }
            debugPrint(commentResponse)
            
        }.resume()
    }
}
