//
//  NoButtonStyle.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/11/22.
//

import SwiftUI

struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
