//
//  ChooseLocationFilterViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/1/22.
//

enum ChooseLocationFilterViewModel: Int, CaseIterable {
    case all
    case education
    case culture
    case occupation
    case funny
    
    var title: String {
        switch self {
        case .all: return "All"
        case .education: return "Education"
        case .culture: return "Culture"
        case .occupation: return "Occupation"
        case .funny: return "Funny"
        }
    }
}
