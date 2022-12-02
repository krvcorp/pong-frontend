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
        
        // LOAD CURRENT STATE
        DispatchQueue.main.async {
            AuthManager.authManager.loadCurrentState()
        }
        
        // MARK: Navigation Bar Styling
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            
            // THE BELOW CODE CHANGES THE NAVBAR TO BE THE COLOR OF THE SYSTEM BACKGROUND
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backgroundColor = UIColor(Color.pongSystemBackground)
            
            // THIS CHANGES THE BACK BUTTON TEXT AND IMAGE TO BE Color.pongAccent
            appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.pongAccent)]
            let image = UIImage(systemName: "chevron.left")?.withTintColor(UIColor(Color.pongAccent), renderingMode: .alwaysOriginal) // fix indicator color
            appearance.setBackIndicatorImage(image, transitionMaskImage: image)
            
            // THIS SETS THE NAVIGATION BAR APPEARANCE FOR ALL TYPES OF APPEARANCES
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(Color.pongAccent)
            
            // THE BELOW CODE CHANGES THE TABBAR APPEARANCE
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            
            // makes the refreshable icon black, and works with list (who knows why)
            UIRefreshControl.appearance().tintColor = UIColor(Color.pongLabel)
            UIRefreshControl.appearance().backgroundColor = UIColor(Color.clear)
            
            // THE BELOW CODE IS SETTING THE ENTIRE APP'S LIST SEPARATOR. IF YOU WANT TO CHANGE THIS, ADD A .ONDISAPPEAR BELOW
            UITableView.appearance().separatorStyle = .none
            UITableViewCell.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            UITableView.appearance().backgroundColor = UIColor(Color.pongSystemBackground)
            
            // Dismiss keyboard on scroll
            UITableView.appearance().keyboardDismissMode = .onDrag
        }
        
        hyperCriticalRulesExample { success in
            if !success {
                // MARK: Firebase messaging config
                if FirebaseApp.app() == nil {
                    FirebaseApp.configure()
                }
                FirebaseConfiguration.shared.setLoggerLevel(.min)
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                
                // LOAD STARTUP STATE some reason this is very inconsistent
                if (AuthManager.authManager.isSignedIn) {
                    DispatchQueue.main.async {
                        DataManager.shared.loadStartupState()
                    }
                }
            }
        }
        
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
                AppState.shared.readPost(url: String(describing: userInfo["url"]!)) { success in
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                        if !DataManager.shared.isAppLoading {
                            AppState.shared.postToNavigateTo = String(describing: userInfo["url"]!)
                            timer.invalidate()
                        }
                    }
                }
            }
        } else if String(describing: userInfo["type"]!) == "leader" {
            // navigate to leaderboard when a leaderboard notification is tapped on
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                if !DataManager.shared.isAppLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AppState.shared.leaderboard = true
                    }
                    timer.invalidate()
                }
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
private extension AppDelegate {
    /// Forces the app to update if the user is on an outdated version. Completion FALSE indicates app is UP TO DATE
    func hyperCriticalRulesExample(completion: @escaping (Bool) -> Void) {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical,
                                          showAlertAfterCurrentVersionHasBeenReleasedForDays: 1)

        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("DEBUG: AlertAction ", updateResults.alertAction)
                print("DEBUG: Localization ", updateResults.localization)
                print("DEBUG: Model ", updateResults.model)
                print("DEBUG: UpdateType ", updateResults.updateType)
                completion(true)
            case .failure(let error):
                print("DEBUG: siren.wail error", error.localizedDescription)
                completion(false)
            }
        }
    }
}
