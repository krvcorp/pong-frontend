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


struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
