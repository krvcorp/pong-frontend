//
//  ProfileFilterViewModel.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import Foundation

enum ProfileFilterViewModel: Int, CaseIterable {
    case posts
    case comments
    case saved
    
    var title: String {
        switch self {
        case .posts: return "Posts"
        case .comments: return "Comments"
        case .saved: return "Saved"
        }
    }
}

