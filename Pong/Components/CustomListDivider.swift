//
//  CustomListDivider.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/27/22.
//

import SwiftUI

struct CustomListDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.gray))
            .frame(maxHeight: 1)
            .listRowBackground(Color(UIColor.systemBackground).edgesIgnoringSafeArea([.leading, .trailing]))
            .listRowSeparator(.hidden)
            .padding(0)
            .listRowInsets(EdgeInsets())
    }
}

struct CustomListDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomListDivider()
    }
}
