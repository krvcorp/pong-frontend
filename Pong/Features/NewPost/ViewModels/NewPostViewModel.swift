//
//  NewPostViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/2/22.
//

import Foundation
import UIKit
import Alamofire

struct NewPostModel: Codable {
    
    struct Request : Encodable {
        let title: String
    }
}

class NewPostViewModel: ObservableObject {
    @Published var image : UIImage? = nil

    // MARK: NewPost request
    func newPost(title: String) -> Void {
        // MARK: if image is not nil then use multipartFormData request
        if image != nil {
            let imgData = (image!).jpegData(compressionQuality: 0.2)!
            
            var httpHeaders: HTTPHeaders = []
            
            if let token = DAKeychain.shared["token"] {
                httpHeaders = [
                    "Authorization": "Token \(token)"
                ]
            }
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(imgData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
            }, to: "\(NetworkManager.networkManager.baseURL)post/", method: .post, headers: httpHeaders)
                .responseDecodable(of: Post.self) { successResponse in
                    print("DEBUG: newPostVM.newPost success \(successResponse)")
            }
        }
        // MARK: else use network manager
        else {
            let parameters = NewPostModel.Request(title: title)
            
            NetworkManager.networkManager.request(route: "post/", method: .post, body: parameters, successType: Post.self) { successResponse in
                // MARK: Success
                DispatchQueue.main.async {

                }
            }
        }
    }
}
