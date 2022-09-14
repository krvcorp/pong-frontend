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
    
    
}
