import Foundation


class NotificationsViewModel: ObservableObject {
    @Published var notificationHistoryWeek: [NotificationsModel] = []
    @Published var notificationHistoryPrevious: [NotificationsModel] = []
    @Published var post: Post = defaultPost
    
    func getNotificationHistoryWeek() {
        NetworkManager.networkManager.request(route: "notifications/?sort=week", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.notificationHistoryWeek = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    func getNotificationHistoryPrevious() {
        NetworkManager.networkManager.request(route: "notifications/?sort=previous", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.notificationHistoryPrevious = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    func getPost(url: String, id: String, completionHandler: @escaping (Post) -> Void) {
        NetworkManager.networkManager.request(route: "\(url)", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.post = successResponse!
                completionHandler(self.post)
            }
            
            if errorResponse != nil {
                self.markNotificationAsRead(id: id)
                DataManager.shared.errorDetected(message: "Something went wrong!", subMessage: "This post was probably deleted.")
            }
        }
    }
    
    // a function to mark a notification as read
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
            }
            if errorResponse != nil {
                debugPrint("Error marking notification as read")
            }
        }
    }
    
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
            }
            if errorResponse != nil {
                debugPrint("Welp, something went wrong.")
            }
        }
    }
}
