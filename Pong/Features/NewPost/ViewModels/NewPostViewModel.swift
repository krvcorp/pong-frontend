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
        let pollOptions: [String]
    }
}

class NewPostViewModel: ObservableObject {
    let characterLimit = 180
    @Published var title : String = "" {
        didSet {
            if title.count > characterLimit && oldValue.count <= characterLimit {
                title = oldValue
            }
        }
    }
    @Published var image : UIImage? = nil
    @Published var newPollVM : NewPollViewModel = NewPollViewModel()

    // MARK: NewPost request
    func newPost(mainTabVM: MainTabViewModel) -> Void {
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
                multipartFormData.append(self.title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(imgData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
            }, to: "\(NetworkManager.networkManager.baseURL)posts/", method: .post, headers: httpHeaders)
                .responseDecodable(of: Post.self) { successResponse in
                    print("DEBUG: newPostVM.newPost success \(successResponse)")
            }
        }
        // MARK: else use network manager
        else {
            print("DEBUG: NewPost with NetworkManager")

            let parameters = NewPostModel.Request(title: self.title, pollOptions: newPollVM.pollOptions)

            NetworkManager.networkManager.request(route: "posts/", method: .post, body: parameters, successType: Post.self) { successResponse, errorResponse in
                // MARK: Success
                if successResponse != nil {
                    DispatchQueue.main.async {
                        mainTabVM.isCustomItemSelected = false
                        mainTabVM.itemSelected = 1
                        mainTabVM.newPostDetected.toggle()
                    }
                }
            }
        }
    }
}
