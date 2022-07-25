//
//  ActionSheets.swift
//  Example
//
//  Created by Alex.M on 20.05.2022.
//

import SwiftUI

#if os(iOS)
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
                Color(UIColor.label)
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

struct ActionSheets_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            SettingsSheetView(loginVM: LoginViewModel(), settingsSheetVM: SettingsSheetViewModel())
        }
        
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            LegalSheetView()
        }
    }
}

#endif
