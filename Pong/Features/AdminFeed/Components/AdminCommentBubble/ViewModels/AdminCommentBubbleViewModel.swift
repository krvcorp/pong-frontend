//
//  AdminCommentBubbleViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import Foundation

class AdminCommentBubbleViewModel: ObservableObject {
    @Published var comment : Comment = defaultComment
    
    func applyTimeout(adminFeedVM: AdminFeedViewModel, time: Int) {
        let parameters = TimeoutModel.Request(time: time)
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/timeout/", method: .post, body: parameters) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let index = adminFeedVM.flaggedComments.firstIndex(of: self.comment) {
                    adminFeedVM.flaggedComments.remove(at: index)
                }
            }
        }
    }
    
    
    func unflagComment(adminFeedVM: AdminFeedViewModel) {
        NetworkManager.networkManager.emptyRequest(route: "comments/\(comment.id)/approve/", method: .post) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let index = adminFeedVM.flaggedComments.firstIndex(of: self.comment) {
                    adminFeedVM.flaggedComments.remove(at: index)
                }
            }
        }
    }
}
