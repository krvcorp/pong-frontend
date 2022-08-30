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
            .fill(Color(UIColor.secondarySystemBackground))
            .frame(height: 1)
            .listRowBackground(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea([.leading, .trailing]))
            .listRowSeparator(.hidden)
    }
}

struct CustomListDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomListDivider()
    }
}
