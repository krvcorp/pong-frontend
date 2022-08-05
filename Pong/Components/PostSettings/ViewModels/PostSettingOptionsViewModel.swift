//
//  PostSettingOptionsViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/25/22.
//

import Foundation

enum PostSettingsOptionsViewModel: Int, CaseIterable {
    case save
    case saved
    case report
    case reported
    case block
    case blocked
    
    var title: String {
        switch self {
            case .save: return "Save Post"
            case .saved: return "Unsave Post"
            case .block: return "Block User"
            case .blocked: return "Unblock User"
            case .report: return "Report Post"
            case .reported: return "Unreport Post"
        }
    }
    
    var imageName: String {
        switch self {
            case .save: return "bookmark"
            case .saved: return "bookmark.fill"
            case .block: return "xmark.circle"
            case .blocked: return "xmark.circle.fill"
            case .report: return "flag"
            case .reported: return "flag.fill"
        }
    }
}
