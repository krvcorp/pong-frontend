//
//  LoadingView.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var isEnabled: Bool
    var content: () -> Content
    
    init (isShowing: Binding<Bool>, isEnabled: Bool = true, content: @escaping () -> Content) {
        self._isShowing = isShowing
        self.isEnabled = isEnabled
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                Color.pongSecondaryText
                    .edgesIgnoringSafeArea(.all)
                    .opacity(self.isShowing ? (self.isEnabled ? 0.69 : 0) : 0)
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    .opacity(self.isShowing ? (self.isEnabled ? 1 : 0) : 0)
            }
        }
    }
}
