//
//  SettingsOptionRowView.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/12/22.
//

import SwiftUI

struct SettingsOptionRowView: View {
    let settingsEnums: SettingsEnums

    var body: some View {
        VStack {
            HStack(spacing: 16) {

                Image(systemName: settingsEnums.imageName)
                    .foregroundColor(.gray)

                Text(settingsEnums.title)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Divider()
        }
    }
}

struct SettingsOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsOptionRowView(settingsEnums: .notifications)
    }
}
