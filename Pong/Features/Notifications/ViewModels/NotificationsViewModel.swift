import Foundation


class NotificationsViewModel: ObservableObject {
    @Published var notificationHistory: [NotificationsModel] = []
    @Published var post: Post = defaultPost
    
    func getNotificationHistory() {
        NetworkManager.networkManager.request(route: "notifications/", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.notificationHistory = successResponse
            } else {
                print(errorResponse?.error ?? "")
            }
        }
    }
    
    func getPost(url: String, completionHandler: @escaping (Post) -> Void) {
        print("DEBUG: \(url)")
        NetworkManager.networkManager.request(route: "\(url)", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.post = successResponse!
                completionHandler(self.post)
            }
            if errorResponse != nil {
                debugPrint("This post was probably deleted")
            }
        }
    }
    
    // a function to mark a notification as read
    func markNotificationAsRead(id: String) {
        NetworkManager.networkManager.emptyRequest(route: "notifications/\(id)/read/", method: .post) { successResponse, errorResponse in
            if successResponse != nil {
                // find the notification in the array and mark it as read
                if let index = self.notificationHistory.firstIndex(where: { $0.id == id }) {
                    self.notificationHistory[index].data.read = true
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
                for i in 0..<self.notificationHistory.count {
                    self.notificationHistory[i].data.read = true
                }
            }
            if errorResponse != nil {
                debugPrint("Welp, something went wrong.")
            }
        }
    }
    
    
}
