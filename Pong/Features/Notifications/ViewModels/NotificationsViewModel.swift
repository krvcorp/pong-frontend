//
//  NotificationsViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/5/22.
//

import Foundation


class NotificationsViewModel: ObservableObject {
    
    @Published var notificationHistory: [NotificationsModel.WrappedNotification] = [NotificationsModel.WrappedNotification]()
    
    func getNotificationHistory() {
        NetworkManager.networkManager.request(route: "notifications/", method: .get, successType: [NotificationsModel.WrappedNotification].self) { successResponse, errorResponse in
            print("ERRORHERENOW")
            if let successResponse = successResponse {
                self.notificationHistory = successResponse
            } else {
                print("ERRORHERENOW")
                print(errorResponse?.error)
            }
        }
    }
}
