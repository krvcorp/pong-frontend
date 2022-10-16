//
//  NewPostViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/2/22.   
//

import Foundation
import UIKit
import Alamofire
import SwiftUI

struct NewPostModel: Codable {
    struct Request : Encodable {
        let title: String
        let pollOptions: [String]
        let tag: String?
    }
}

// MARK: TagEnum
enum Tag: String, CaseIterable, Identifiable {
    case none, rant, confession, question, event, meme, w, rip, course
    var id: Self { self }
    
    var title: String? {
        switch self {
        case .none: return nil
        case .rant: return "RANT"
        case .confession: return "CONFESSION"
        case .question: return "QUESTION"
        case .event: return "EVENT"
        case .meme: return "MEME"
        case .w: return "W"
        case .rip: return "RIP"
        case .course: return "CLASS"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return Color(UIColor.clear)
        case .rant: return Color(.red)
        case .confession: return Color(.blue)
        case .question: return Color(.orange)
        case .event: return Color(.green)
        case .meme: return Color.earlyPeriod1
        case .w: return Color.poshGold
        case .rip: return Color(.black)
        case .course: return Color.poshDarkRed
        }
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
    @Published var selectedTag : Tag = .none
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
                if let tag = self.selectedTag.title {
                    multipartFormData.append(tag.data(using: String.Encoding.utf8)!, withName: "tag")
                }
            }, to: "\(NetworkManager.networkManager.baseURL)posts/", method: .post, headers: httpHeaders)
                .responseDecodable(of: Post.self) { successResponse in
                    print("DEBUG: newPostVM.newPost success \(successResponse)")
                    DispatchQueue.main.async {
                        mainTabVM.newPost()
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
            
            let parameters = NewPostModel.Request(title: self.title, pollOptions: pollOptions, tag: self.selectedTag.title)
            
            // validate newPoll doesn't have invalid entries
            if newPollVM.validate() {
                NetworkManager.networkManager.request(route: "posts/", method: .post, body: parameters, successType: Post.self) { successResponse, errorResponse in
                    if successResponse != nil {
                        DispatchQueue.main.async {
                            mainTabVM.newPost()
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
