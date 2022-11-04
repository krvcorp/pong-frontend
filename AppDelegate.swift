//
//  AppDelegate.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/2/22.
//

import FirebaseCore
import UIKit
import FirebaseMessaging
import Siren
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // MARK: Firebase messaging config
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // MARK: Navigation Bar Styling
        // makes a white opaque navigation bar
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backgroundColor = UIColor(Color.pongSystemBackground)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // THE BELOW CODE CHANGES THE NAVBAR
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            
            // THE BELOW CODE IS SETTING THE ENTIRE APP'S LIST SEPARATOR. IF YOU WANT TO CHANGE THIS, ADD A .ONDISAPPEAR BELOW
            UITableView.appearance().separatorStyle = .none
            UITableViewCell.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            UITableView.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            
            // Dismiss keyboard on scroll
            UIScrollView.appearance().keyboardDismissMode = .onDrag
        }
        
        // MARK: HyperCriticalRulesExample
        hyperCriticalRulesExample()
        
        return true
    }
}

// MARK: Notifications
/// All things related to notifications are in here
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: willPresent
    /// Determines course of action when a notification is received while the app is in the foreground. Currently just pings an Apple notification as normally
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("DEBUG: willPresent")
        _ = notification.request.content.userInfo
        
        return [[.banner, .list, .sound]]
    }
    
    // MARK: didReceive
    /// Determines course of action when a notfication is tapped on. It simply navigates into the app and opens a NavigationPane based on the notification that was tapped on
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("DEBUG: didReceive")
        let userInfo = response.notification.request.content.userInfo
        
        if String(describing: userInfo["type"]!) == "hot" || String(describing: userInfo["type"]!) == "upvote" || String(describing: userInfo["type"]!) == "comment" || String(describing: userInfo["type"]!) == "top" || String(describing: userInfo["type"]!) == "reply" {
            // navigate to post when a post notification is tapped on
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppState.shared.postToNavigateTo = String(describing: userInfo["url"]!)
                AppState.shared.readPost(url: String(describing: userInfo["url"]!))
            }
        } else if String(describing: userInfo["type"]!) == "leader" {
            // navigate to leaderboard when a leaderboard notification is tapped on
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppState.shared.leaderboard = true
            }
        } else if String(describing: userInfo["type"]!) == "message" {
            // navigate to message view when a message notificaiton is tapped on
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppState.shared.conversationToNavigateTo = String(describing: userInfo["url"]!)
                AppState.shared.readConversation(url: String(describing: userInfo["url"]!))
            }
        }
    }
    
    // MARK: Enabling Notifications
    /// Something with enabling notifications
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

//Messaging is Firebase’s class that manages everything related to push notifications.
//Like a lot of iOS APIs, it features a delegate called MessagingDelegate,
//which you implement in the code above. Whenever your app starts up or
//Firebase updates your token, Firebase will call the method you just added to
//keep the app in sync with it.
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil,
                                        userInfo: tokenDict)
    }
}

// MARK: HyperCriticalRules
/// Forces the app to update if the user is on an outdated version
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
