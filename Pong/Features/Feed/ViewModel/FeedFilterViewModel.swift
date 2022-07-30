//
//  FeedFilterViewModel.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import Foundation

enum FeedFilterViewModel: Int, CaseIterable {
    case top
    case hot
    case recent
//    case forYou
    
    var title: String {
        switch self {
        case .top: return "Top"
        case .hot: return "Hot"
        case .recent: return "Recent"
//        case .forYou: return "For You"
        }
    }
}
