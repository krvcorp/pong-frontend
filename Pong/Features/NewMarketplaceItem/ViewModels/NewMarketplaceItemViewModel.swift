//
//  NewMarketplaceItemViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import Foundation

class NewMarketplaceItemViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var price = ""
    @Published var image = ""
}
