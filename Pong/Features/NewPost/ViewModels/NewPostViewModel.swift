//
//  NewPostViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/2/22.
//

import Foundation

class NewPostViewModel: ObservableObject {
    @Published var error = false

    func newPost(title: String) -> Void {
        
        let parameters = PostRequestBody(title: title)
        
        NetworkManager.networkManager.request(route: "post/", method: .post, body: parameters, successType: Post.self) { successResponse in
            // MARK: Success
            DispatchQueue.main.async {
                
            }
        }
    }
}
