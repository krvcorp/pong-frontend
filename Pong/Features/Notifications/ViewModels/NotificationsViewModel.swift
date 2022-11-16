import Foundation
import UIKit

class NotificationsViewModel: ObservableObject {
    @Published var post: Post = defaultPost
    @Published var isDoneLoading = false
    
    // MARK: GetNotificationsHistoryWeek
    /// Gets the notifications from within the current week timeframe
    func getNotificationHistoryWeek() {
        NetworkManager.networkManager.request(route: "notifications/?sort=week", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DataManager.shared.notificationHistoryWeek = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    // MARK: GetNotificationsHistoryPrevious
    /// Gets the notifications from history before the current week timeframe
    func getNotificationHistoryPrevious() {
        NetworkManager.networkManager.request(route: "notifications/?sort=previous", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DataManager.shared.notificationHistoryPrevious = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }

    // MARK: Get Notifications
    func getAllNotifications() {
        NetworkManager.networkManager.request(route: "notifications/?sort=week", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DataManager.shared.notificationHistoryWeek = successResponse

                // previous notifications
                NetworkManager.networkManager.request(route: "notifications/?sort=previous", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
                    if let successResponse = successResponse {
                        DataManager.shared.notificationHistoryPrevious = successResponse
                        self.isDoneLoading = true
                    } else {
                        print(errorResponse?.error ?? "")
                    }
                }

            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    // MARK: GetPost
    /// Gets the post of a particular notification
    func getPost(url: String, id: String, completionHandler: @escaping (Post) -> Void) {
        NetworkManager.networkManager.request(route: "\(url)", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.post = successResponse!
                completionHandler(self.post)
            }
            
            if errorResponse != nil {
                ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "This post was probably deleted.")
            }
            self.markNotificationAsRead(id: id)
        }
    }
    
    // MARK: MarkNotificationAsRead
    /// Marks a particular notification as read. Will decrement the badge number
    func markNotificationAsRead(id: String) {
        NetworkManager.networkManager.emptyRequest(route: "notifications/\(id)/read/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                // find the notification in the array and mark it as read
                if let index = DataManager.shared.notificationHistoryWeek.firstIndex(where: { $0.id == id }) {
                    DataManager.shared.notificationHistoryWeek[index].data.read = true
                }
                else if let index = DataManager.shared.notificationHistoryPrevious.firstIndex(where: { $0.id == id }) {
                    DataManager.shared.notificationHistoryPrevious[index].data.read = true
                }
                // decrement badge count by 1
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
            if errorResponse != nil {
                debugPrint("Error marking notification as read")
            }
        }
    }
    
    // MARK: MarkAllNotificationsAsRead
    /// Marks all notifications as read. Will set the badge number as 0
    func markAllAsRead() {
        NetworkManager.networkManager.emptyRequest(route: "notifications/readall/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                // iterate through all notifications and mark them as read
                for i in 0..<DataManager.shared.notificationHistoryWeek.count {
                    DataManager.shared.notificationHistoryWeek[i].data.read = true
                }
                for i in 0..<DataManager.shared.notificationHistoryPrevious.count {
                    DataManager.shared.notificationHistoryPrevious[i].data.read = true
                }
                // set badge count to 0
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            if errorResponse != nil {
                debugPrint("Welp, something went wrong.")
            }
        }
    }
}
