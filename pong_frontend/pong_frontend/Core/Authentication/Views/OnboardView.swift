//
//  OnboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import UIKit
import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

let signInConfig = GIDConfiguration(clientID: "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")

struct OnboardView: View {
    @Binding var email: String
    @Binding var password: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var loginVM : LoginViewModel
    
    
    var body: some View {

        VStack {
            VStack(alignment: .leading) {
                Text("Sign up or log in with your email")
                    .font(.title).bold()
                TextField("example@example.com", text: $loginVM.email_or_username)
                    .accentColor(.secondary)
                    .font(.title.bold())
                SecureField("admin", text: $loginVM.password)
                    .accentColor(.secondary)
                    .font(.title.bold())
            }
            
            Spacer()
            
            VStack {
                Text("By pressing continue you agree to receive a text message from us")
             
                Button(action: {
                    print("DEBUG: SIGN IN")
                    print("DEBUG: SIGN OUT")
                    loginVM.login()
                }) {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.primary, lineWidth: 2)
                    )
                }
                .background(Color(UIColor.label)) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
                
                Button {
                    handleSignInButton()
                } label: {
                    Text("Awake")
                }

//                GoogleSignInButton(action: handleSignInButton)
            }
        }
        .padding(20)
    }
}

func handleSignInButton() {
    guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
        print("There is no root view controller!")
        return
    }
    
    GIDSignIn.sharedInstance.signIn(
        with: signInConfig,
        presenting: presentingViewController) { user, error in
        guard let signInUser = user else {
            // Inspect error
            return
        }
    // If sign in succeeded, display the app's main content View.
            ContentView()
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



//struct OnboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardView(email: .constant(""), password: .constant(""))
//    }
//}
