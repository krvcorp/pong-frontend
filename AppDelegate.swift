//
//  AppDelegate.swift
//  Pong
//
//  Created by Artemas on 8/2/22.
//

import FirebaseCore
import UIKit
import FirebaseMessaging
import Siren
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UserDefaults.standard.set(true, forKey: "Text Messages")
        
        // White non-transucent navigatio bar, supports dark appearance
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        hyperCriticalRulesExample()
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // ...

        // Print full message.
//        print("DEBUG: first function")
//        print("DEBUG: \(userInfo)")

        // Change this to your preferred presentation option
        return [[.alert, .sound]]
    }
    
    // MARK: I don't know what this function does
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        // ...

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
//        print("DEBUG: second function")
//        print("DEBUG: \(userInfo)")
        
//        print("DEBUG: \(String(describing: userInfo["url"]))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            print("Dispatch")
            AppState.shared.pageToNavigationTo = String(describing: userInfo["url"]!)
            AppState.shared.readPost(url: String(describing: userInfo["url"]!))
        }
    }
    
    // MARK: Enabling Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil,userInfo: tokenDict)
    }
}

private extension AppDelegate {
    func hyperCriticalRulesExample() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical,
                                          showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)

        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
