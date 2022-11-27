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
        case .none: return "nil"
        case .rant: return "Rant"
        case .confession: return "Confession"
        case .question: return "Question"
        case .event: return "Event"
        case .meme: return "Meme"
        case .w: return "W"
        case .rip: return "RIP"
        case .course: return "Class"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return Color(UIColor.clear)
        case .rant: return Color(.red)
        case .confession: return Color(.blue)
        case .question: return Color(.orange)
        case .event: return Color(.brown)
        case .meme: return Color(.purple)
        case .w: return Color(.systemYellow)
        case .rip: return Color(.darkGray)
        case .course: return Color(.magenta)
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
    
    @Published var newPostLoading = false
    
    @Published var error = false
    @Published var errorMessage = "Error"

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
            
            let decoder: JSONDecoder = {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }()

            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(self.title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(imgData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
                if let tag = self.selectedTag.title?.lowercased() {
                    multipartFormData.append(tag.data(using: String.Encoding.utf8)!, withName: "tag")
                }
            }, to: "\(NetworkManager.networkManager.baseURL)posts/", method: .post, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            self.errorDetect(message: "Unable to connect to network")
                        }
                        self.newPostLoading = false
                    }
                }
                .responseDecodable(of: Post.self, decoder: decoder) { (response) in
                    guard let success = response.value else { return }
                    
                    DispatchQueue.main.async {
                        self.newPostLoading = false
                        mainTabVM.newPost()
                        dataManager.initProfile()
                    }
                }
                .responseDecodable(of: ErrorResponseBody.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    self.newPostLoading = false
                    self.errorDetect(message: error.error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        self.newPostLoading = false
                        self.errorDetect(message: "Unable to connect to network")
                        break
                    }
                }
        }
        // MARK: else use network manager
        else {
            var pollOptions = newPollVM.pollOptions
            
            if newPollVM.allowSkipVoting {
                pollOptions.append("skipkhoicunt")
            }
            
            print("DEBUG: \(pollOptions)")
            let parameters = NewPostModel.Request(title: self.title, pollOptions: pollOptions, tag: self.selectedTag.title?.lowercased())
            
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
                            self.errorDetect(message: "\(errorResponse.error)")
                            self.newPostLoading = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorDetect(message: "Invalid empty entries!")
                    self.newPostLoading = false
                }
            }
        }
    }
    
    func errorDetect(message : String) {
        DispatchQueue.main.async {
            self.error = true
            self.errorMessage = message
        }
    }
}
