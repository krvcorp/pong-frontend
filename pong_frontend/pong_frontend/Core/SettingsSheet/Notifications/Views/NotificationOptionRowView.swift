//
//  NotificationOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct NotificationOptionRowView: View {
    let notificationsSheetEnum: NotificationsSheetEnum
    @State private var vibrateOnRing = false

    var body: some View {
        VStack {
            HStack() {
                Toggle(isOn: $vibrateOnRing) {
                    Image(systemName: notificationsSheetEnum.imageName)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                    
                    Text(notificationsSheetEnum.title)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(UIColor.label))
                    Spacer()
                }
            }
            .frame(height: 40)
            .padding(.leading)

            Divider()
        }
        .background(Color(UIColor.secondarySystemBackground)) // necessary for clickable background
    }
}

struct NotificationOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationOptionRowView(notificationsSheetEnum: .announcements)
    }
}
