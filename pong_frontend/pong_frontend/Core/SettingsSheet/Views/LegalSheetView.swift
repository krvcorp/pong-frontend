//
//  LegalSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/22/22.
//

import SwiftUI

struct LegalSheetView: View {
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    var body: some View {
        ActionSheetView(bgColor: .white) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.system(size: 24))
                    
                    Text("This is going to be a link redirect")
                        .font(.system(size: 14))
                        .opacity(0.6)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct LegalSheetView_Previews: PreviewProvider {
    static var previews: some View {
        LegalSheetView(settingsSheetVM: SettingsSheetViewModel())
    }
}
