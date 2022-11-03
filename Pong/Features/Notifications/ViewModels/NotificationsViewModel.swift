import Foundation
import UIKit

class NotificationsViewModel: ObservableObject {
    @Published var notificationHistoryWeek: [NotificationsModel] = []
    @Published var notificationHistoryPrevious: [NotificationsModel] = []
    @Published var post: Post = defaultPost
    
    // MARK: GetNotificationsHistoryWeek
    /// Gets the notifications from within the current week timeframe
    func getNotificationHistoryWeek() {
        NetworkManager.networkManager.request(route: "notifications/?sort=week", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.notificationHistoryWeek = successResponse
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
                self.notificationHistoryPrevious = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    // MARK: GetPost
    /// Gets the post of a particular notification
    func getPost(url: String, id: String, completionHandler: @escaping (Post) -> Void) {
        NetworkManager.networkManager.request(route: "posts/\(url)/", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.post = successResponse!
                completionHandler(self.post)
            }
            
            if errorResponse != nil {
                DataManager.shared.errorDetected(message: "Something went wrong!", subMessage: "This post was probably deleted.")
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
                if let index = self.notificationHistoryWeek.firstIndex(where: { $0.id == id }) {
                    self.notificationHistoryWeek[index].data.read = true
                }
                if let index = self.notificationHistoryPrevious.firstIndex(where: { $0.id == id }) {
                    self.notificationHistoryPrevious[index].data.read = true
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
                for i in 0..<self.notificationHistoryWeek.count {
                    self.notificationHistoryWeek[i].data.read = true
                }
                for i in 0..<self.notificationHistoryPrevious.count {
                    self.notificationHistoryPrevious[i].data.read = true
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
