//
//  BackButton.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct BackButton: View {
    var body: some View {
        Image(systemName: "chevron.backward")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color(UIColor.label))
            .frame(minWidth: 10, maxWidth: 15)
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton()
    }
}
