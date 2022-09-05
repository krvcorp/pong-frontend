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
    let characterLimit = 280
    @Published var title : String = "" {
        didSet {
            if title.count > characterLimit && oldValue.count <= characterLimit {
                title = oldValue
            }
        }
    }
    @Published var image : UIImage? = nil
    @Published var newPollVM : NewPollViewModel = NewPollViewModel()
    @Published var error = false
    @Published var errorMessage = "Error"
    @Published var newPostLoading = false

    // MARK: NewPost request
    func newPost(mainTabVM: MainTabViewModel, dataManager: DataManager) -> Void {
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
                    DispatchQueue.main.async {
                        mainTabVM.isCustomItemSelected = false
                        mainTabVM.itemSelected = 1
                        mainTabVM.newPostDetected.toggle()
                        dataManager.initProfile()
                    }
                }
        }
        // MARK: else use network manager
        else {
            var pollOptions = newPollVM.pollOptions
            
            if newPollVM.allowSkipVoting {
                pollOptions.append("skipkhoicunt")
            }
            
            let parameters = NewPostModel.Request(title: self.title, pollOptions: pollOptions)
            
            // validate newPoll doesn't have invalid entries
            if newPollVM.validate() {
                NetworkManager.networkManager.request(route: "posts/", method: .post, body: parameters, successType: Post.self) { successResponse, errorResponse in
                    if successResponse != nil {
                        DispatchQueue.main.async {
                            mainTabVM.isCustomItemSelected = false
                            mainTabVM.itemSelected = 1
                            mainTabVM.newPostDetected.toggle()
                            dataManager.initProfile()
                        }
                    }
                    if let errorResponse = errorResponse {
                        DispatchQueue.main.async {
                            self.errorMessage = errorResponse.error
                            self.error = true
                            self.newPostLoading = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid empty entries!"
                    self.error = true
                    self.newPostLoading = false
                }
            }
        }
    }
}
