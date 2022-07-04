//
//  PongMockupApp.swift
//  PongMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//
// info plist Product Name used to be $(TARGET_NAME)
// 983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com

import SwiftUI
import GoogleSignIn

@main
struct Pong: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//class AppDelegate: UIResponder, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//        GIDSignIn.sharedInstance().clientID = "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com"
//
//        return true
//    }
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//
//        return (GIDSignIn.sharedInstance()?.handle(url))!
//    }
//}
//
//class ViewController: UIViewController, GIDSignInDelegate {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        GIDSignIn.sharedInstance()?.delegate = self
//    }
//
//    @IBAction func googleLogin(_ sender: Any) {
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//
//        GIDSignIn.sharedInstance()?.signIn()
//    }
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error != nil {
//            print("DEBUG: \(user.userID!)")
//        }
//    }
//}
