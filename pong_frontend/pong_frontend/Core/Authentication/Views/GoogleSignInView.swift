//
//  GoogleSignInView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/8/22.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

let signInConfig = GIDConfiguration(clientID: "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")

struct GoogleSignInView: View {
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var phoneLoginVM : PhoneLoginViewModel
    
    var body: some View {
        Text("Your phone number is \(phoneLoginVM.phone)")
        Text("Your token is \(phoneLoginVM.token)")
        
        Button {
            print("DEBUG: VIEW GoogleSignIn")
            handleSignInButton()
        } label: {
            Text("Google Sign In")
        }
    }
}


func handleSignInButton() {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    
    guard let presentingViewController = window!.rootViewController else {
        print("There is no root view controller!")
        return
    }
    
    // Depreciated above should fix?
//    guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
//        print("There is no root view controller!")
//        return
//    }
    
    GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: presentingViewController) { user, error in
        guard error == nil else { return }
        guard let user = user else { return }

        let emailAddress = user.profile?.email
        print("DEBUG: emailAddress is \(String(describing: emailAddress))")
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }

        // Handle other custom URL types.

        // If not handled by this app, return false.
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if error != nil || user == nil {
                  // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
        }
        return true
        }
    }

struct GoogleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInView(loginVM: LoginViewModel(), phoneLoginVM: PhoneLoginViewModel())
    }
}
