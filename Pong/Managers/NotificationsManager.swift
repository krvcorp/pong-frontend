import Foundation
import Firebase
import SwiftUI

class NotificationsManager: ObservableObject {
    
    static let shared = NotificationsManager()
    
    let defaults = UserDefaults.standard
    
    struct Registration {
        struct Request: Encodable { let fcm_token: String }
        struct Success: Decodable {}
    }
    
    struct Settings {
        struct Request: Encodable { let enabled: Bool }
        struct Success: Decodable {}
    }
    
    @Published var notificationsPreference: Bool = false
    
    init() {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                self.notificationsPreference = true
            } else {
                self.notificationsPreference = false
            }
        })
    }
    
    // MARK: RegisterForNotifications
    /// Attempts to register for notifications. If the user hasn't registered for notifications before, it will prompt the user to turn on notifications. Once that has been set, the user will no longer be prompted to turn on notifications
    func registerForNotifications(forceRegister: Bool) {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined || forceRegister {
                // Notification permission has not been asked yet, go for it!
                Messaging.messaging().token { token, error in
                    if let token = token {
                        // save fcm token
                        DAKeychain.shared["fcm"] = token
                        
                        // send fcm token
                        NetworkManager.networkManager.emptyRequest(route: "notifications/register/", method: .post, body: Registration.Request(fcm_token: token)) { success, error in
                            print("DEBUG: Notifications Registered")
                        }
                        
                        // ask for permission
                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in

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
    
    // MARK: UpdateNotificationsPreferences
    /// Determines if the user has notification settings on, and if it isn't, displays a CTA to turn on notifications
    func updateNotificationsPreferences() {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.notificationsPreference = true
                } else {
                    self.notificationsPreference = false
                }
            }
        })
    }
    
    // MARK: Remove FCM Token
    /// Send a network request to delete the user's FCM token. This will prevent notifications to be sent to the device the user just signed out of
    func removeFCMToken(completion: @escaping (Bool) -> Void) {
        Messaging.messaging().token { token, error in
            if let token = token {
                // send fcm token
                NetworkManager.networkManager.emptyRequest(route: "notifications/register/", method: .delete, body: Registration.Request(fcm_token: token)) { successResponse, errorResponse in
                    
                    if successResponse != nil {
                        completion(true)
                    }
                    
                    if errorResponse != nil {
                        print("DEBUG: unable to remove fcm token")
                    }
                }
            }
        }
    }
}
