//
//  MarketplaceItem.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/26/22.
//

import Foundation

struct MarketplaceItem: Hashable, Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var images: [Image]
    var sold: Bool
    var price: String
    var date : String
    
    struct Image: Hashable, Identifiable, Codable {
        var id: String
        var image: String
        var featured: Bool
    }
}
