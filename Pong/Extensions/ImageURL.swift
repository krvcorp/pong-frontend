//
//  ImageURL.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/30/22.
//

import Foundation
import SwiftUI

extension Image {

    func data(url:URL) -> Self {

    if let data = try? Data(contentsOf: url) {
        return Image(uiImage: UIImage(data: data)!).resizable()
    }

    return self.resizable()

    }

}
