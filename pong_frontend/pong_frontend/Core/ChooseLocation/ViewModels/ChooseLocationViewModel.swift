//
//  ChooseLocationViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/1/22.
//

import Foundation

enum ChooseLocationViewModel: Int, CaseIterable {
    case harvard
    case mit
    case uva
    case vt
    
    var title: String {
        switch self {
        case .harvard: return "Harvard"
        case .mit: return "MIT"
        case .uva: return "UVA"
        case .vt: return "VT"
        }
    }
}
