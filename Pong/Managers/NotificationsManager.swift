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
    
    func registerForNotifications() {
        Messaging.messaging().token { token, error in
            if let token = token {
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
                    NetworkManager.networkManager.emptyRequest(route: "notifications/register/", method: .post, body: Registration.Request(fcm_token: token)) { success, error in
                        print("success")
                        self.hasEnabledNotificationsOnce = true
                        self.notificationsPreference = true
                    }
                }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    @Published var notificationsPreference: Bool = false {
        didSet {
            defaults.set(notificationsPreference, forKey: "notificationsPreference")
            NetworkManager.networkManager.request(route: "notifications/settingshandler/", method: .post, body: Settings.Request(enabled: notificationsPreference), successType: Settings.Success.self) { success, error in
                if success != nil {
                    print("success")
                    self.defaults.set(self.notificationsPreference, forKey: "notificationsPreference")
                }
            }
        }
    }
    
    @Published var hasEnabledNotificationsOnce: Bool = false {
        didSet {
            defaults.set(hasEnabledNotificationsOnce, forKey: "hasEnabledNotificationsOnce")
        }
    }
    
    init() {
        hasEnabledNotificationsOnce = defaults.bool(forKey: "hasEnabledNotificationsOnce")
        notificationsPreference = defaults.bool(forKey: "notificationsPreference")
    }
}
