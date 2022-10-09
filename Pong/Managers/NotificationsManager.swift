import Foundation
import Firebase
import SwiftUI

class NotificationsManager: ObservableObject {
    
    static let notificationsManager = NotificationsManager()
    
    let defaults = UserDefaults.standard
    
    struct Registration {
        struct Request: Encodable { let fcm_token: String }
        struct Success: Decodable {}
    }
    
    struct Settings {
        struct Request: Encodable { let enabled: Bool }
        struct Success: Decodable {}
    }
    
    var notificationsPreference : String = ""
    
    func registerForNotifications() {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                Messaging.messaging().token { token, error in
                    if let token = token {
                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
                            NetworkManager.networkManager.emptyRequest(route: "notifications/register/", method: .post, body: Registration.Request(fcm_token: token)) { success, error in
                                print("DEBUG: Notifications Registered")
                            }
                        }
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                print("DEBUG: Notifications Denied")
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                print("DEBUG: Notifications Authorized")
            }
        })
    }
    
    func notificationsState() {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                print("DEBUG: Not Determined")
                self.notificationsPreference = "Not determined"
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                print("DEBUG: Denied")
                self.notificationsPreference = "Denied"
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                print("DEBUG: Authorized")
                self.notificationsPreference = "Authorized"
            }
        })
    }
}
