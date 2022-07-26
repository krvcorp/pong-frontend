//
//  PreferencesOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct PreferencesOptionRowView: View {
    let preferencesSettingsEnum: PreferencesSettingsEnum
    @State private var vibrateOnRing = false

    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $vibrateOnRing) {
                    Image(systemName: preferencesSettingsEnum.imageName)
                        .foregroundColor(.gray)
                    
                    Text(preferencesSettingsEnum.title)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(UIColor.label))
                }
                Spacer()
            }
            .frame(height: 40)
            .padding(.leading)

            Divider()
        }
        .background(Color(UIColor.secondarySystemBackground)) // necessary for clickable background
    }
}

struct PreferencesOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesOptionRowView(preferencesSettingsEnum: .darkMode)
    }
}
