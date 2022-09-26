//
//  NewMarketplaceItemViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import Foundation

class NewMarketplaceItemViewModel: ObservableObject {
    @Published var title = ""
    @Published var price = ""
    @Published var size = ""
    @Published var brand = ""
    @Published var description = ""
}
