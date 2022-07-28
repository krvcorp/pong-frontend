//
//  PostSettingOptionsViewModel.swift
//  Pong
//
//  Created by Raunak Daga on 7/25/22.
//

import Foundation

enum PostSettingsOptionsViewModel: Int, CaseIterable {
    case save
    case report
    case block
    
    var title: String {
        switch self {
        case .save: return "Save Post"
        case .block: return "Block User"
        case .report: return "Report Post"
        }
    }
    
    var imageName: String {
        switch self {
        case .save: return "bookmark"
        case .block: return "xmark.circle"
        case .report: return "flag"
        }
    }
}
