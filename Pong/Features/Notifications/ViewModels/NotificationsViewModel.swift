import Foundation


class NotificationsViewModel: ObservableObject {
    @Published var notificationHistory: [NotificationsModel.WrappedNotification] = [NotificationsModel.WrappedNotification]()
    @Published var post: Post = defaultPost
    
    func getNotificationHistory() {
        NetworkManager.networkManager.request(route: "notifications/", method: .get, successType: [NotificationsModel.WrappedNotification].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                self.notificationHistory = successResponse
            } else {
                print(errorResponse?.error)
            }
        }
    }
    
    func getPost(url: String) {
        NetworkManager.networkManager.request(route: "\(url)", method: .get, successType: Post.self) { successResponse, errorResponse in
            if successResponse != nil {
                self.post = successResponse!
            }
            if errorResponse != nil {
                debugPrint("This post was probably deleted")
            }
        }
    }
    
    
}
