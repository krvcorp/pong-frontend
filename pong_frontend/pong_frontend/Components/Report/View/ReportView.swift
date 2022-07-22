//
//  ReportView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        ActionSheetView(bgColor: .white) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Item 1")
                    Text("Item 2")
                    Text("Item 3")
                    Text("Item 4")
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ActionSheetView<Content: View>: View {

    let content: Content
    let topPadding: CGFloat
    let fixedHeight: Bool
    let bgColor: Color

    init(topPadding: CGFloat = 100, fixedHeight: Bool = false, bgColor: Color = .white, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.topPadding = topPadding
        self.fixedHeight = fixedHeight
        self.bgColor = bgColor
    }

    var body: some View {
        ZStack {
            bgColor.cornerRadius(40, corners: [.topLeft, .topRight])
            VStack {
                Color.black
                    .opacity(0.2)
                    .frame(width: 30, height: 6)
                    .clipShape(Capsule())
                    .padding(.top, 15)
                    .padding(.bottom, 10)

                content
                    .padding(.bottom, 30)
                    .applyIf(fixedHeight) {
                        $0.frame(height: UIScreen.main.bounds.height - topPadding)
                    }
                    .applyIf(!fixedHeight) {
                        $0.frame(maxHeight: UIScreen.main.bounds.height - topPadding)
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
