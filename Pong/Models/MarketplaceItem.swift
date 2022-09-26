//
//  MarketplaceItem.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/26/22.
//

import Foundation

struct MarketplaceItem: Hashable, Identifiable, Codable {
    var id: String
    var title: String
    var price: String
    var image: String
    var date: String
}
