//
//  ProminentHeaderModifier.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import Foundation
import SwiftUI

struct ProminentHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(content.headerProminence(Prominence.increased))
        } else {
            return AnyView(content)
        }
    }
}
