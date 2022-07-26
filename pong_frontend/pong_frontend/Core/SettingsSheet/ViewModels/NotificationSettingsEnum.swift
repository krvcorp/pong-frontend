//
//  NotificationSettingsEnum.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

enum NotificationSettingsEnum: Int, CaseIterable {
    case announcements
    // post
    case upvotesOnPost
    case commentsOnPost
    // comment
    case upvotesOnComments
    case repliesToComments
    
    var title: String {
        switch self {
        case .announcements: return "Announcements"
        case .upvotesOnPost: return "Upvotes to your posts"
        case .commentsOnPost: return "Comments to your post"
        case .upvotesOnComments: return "Upvotes to your comments"
        case .repliesToComments: return "Replies to your comments"
        }
    }
    
    var imageName: String {
        switch self {
        case .announcements: return "megaphone"
        case .upvotesOnPost: return "arrow.up"
        case .commentsOnPost: return "bubble.left"
        case .upvotesOnComments: return "chevron.up"
        case .repliesToComments: return "bubble.left.and.bubble.right"
        }
    }
}
