//
//  NotificationSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/26/22.
//

import SwiftUI
import FirebaseMessaging

struct NotificationsSheetView: View {
    @ObservedObject var settingsSheetVM: SettingsSheetViewModel
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            VStack {
                // HEADER
                ZStack {
                    HStack() {
                        Button {
                            print("DEBUG: PreferencesSheetView Back")
                            settingsSheetVM.showSettingsSheetView = true
                            settingsSheetVM.showNotificationsSheetView = false
                        } label: {
                            BackButton()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Notifications")
                        .font(.title.bold())
                }
                // BODY
                VStack(alignment: .leading, spacing: 32) {
                    Button(action: {
                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
                        UIApplication.shared.registerForRemoteNotifications()
                    }) {
                        Text("Register for APNS")
                    }
                    Button(action: {
                        Messaging.messaging().token { token, error in
                          if let error = error {
                              UIPasteboard.general.string = "Error Fetching FCM Registration Token: \(error)"
                          } else if let token = token {
                              UIPasteboard.general.string = token
                          }
                        }
                    }) {
                        Text("Copy FCM Token")
                    }
                    ForEach(NotificationsSheetEnum.allCases, id: \.rawValue) { notificationsSheetEnum in
                        NotificationOptionRowView(notificationsSheetEnum: notificationsSheetEnum)
                    }
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal, 20)
            }
        }
    }
}

struct NotificationSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSheetView(settingsSheetVM: SettingsSheetViewModel())
    }
}
