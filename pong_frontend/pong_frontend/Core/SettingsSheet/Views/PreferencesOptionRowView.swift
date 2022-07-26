//
//  PreferencesOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct PreferencesOptionRowView: View {
    let preferenceSettingsEnum: PreferenceSettingsEnum
    @State private var vibrateOnRing = false

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: preferenceSettingsEnum.imageName)
                    .foregroundColor(.gray)

                Toggle(isOn: $vibrateOnRing) {
                    Text(preferenceSettingsEnum.title)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(UIColor.label))
                }
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)

            Divider()
        }
    }
}

struct PreferencesOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesOptionRowView(preferenceSettingsEnum: .darkMode)
    }
}
