//
//  AuthManager.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/29/22.
//

import Foundation
import GoogleSignIn
import Alamofire

class AuthManager: ObservableObject {
    
    static let authManager: AuthManager = AuthManager()
    
    @Published var isSignedIn: Bool = false
    @Published var initialOnboard: Bool = false
    @Published var userId: String = ""
    @Published var isAdmin: Bool = false
    
    // MARK: Current State is determined if the userId and the token is stored to the keychain
    func loadCurrentState() {
        isSignedIn = (DAKeychain.shared["userId"] != nil && DAKeychain.shared["token"] != nil)
        if let userId = DAKeychain.shared["userId"] {
            self.userId = userId
        }
        if DAKeychain.shared["isAdmin"] != nil {
            self.isAdmin = true
        }
        
        print("DEBUG: \(isSignedIn)")
    }
    
    // MARK: Signout sets keychain to nil
    func signout() {
        DispatchQueue.main.async {
            self.initialOnboard = true
            AuthManager.authManager.isSignedIn = false
            GIDSignIn.sharedInstance.disconnect() // don't think this is necessary but idk?
            DAKeychain.shared["userId"] = nil
            DAKeychain.shared["token"] = nil
        }
    }
    
    // MARK: Google OAuth2.0
    let signInConfig = GIDConfiguration(clientID: "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")

    func googleSignInButton() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        guard let presentingViewController = window!.rootViewController else {
            print("There is no root view controller!")
            return
        }

        // MARK: Send token returned from Google via POST verifyEmail
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: presentingViewController) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            user.authentication.do { authentication, error in
                guard error == nil else { return }
                guard let authentication = authentication else { return }

                let idToken = authentication.idToken
                // Send ID token to backend (example below).
                self.verifyEmail(idToken: idToken!)
            }
        }
    }
    
    // MARK: POST to verifyEmail and authenticate session
    private func verifyEmail(idToken: String) {
        
        let parameters = VerifyEmailModel.Request(idToken: idToken)
        
        NetworkManager.networkManager.request(route: "login/", method: .post, body: parameters, successType: VerifyEmailModel.Response.self) { successResponse in
            // MARK: User is signed in
            DispatchQueue.main.async {
                if let token = successResponse.token {
                    print("DEBUG: token \(token)")
                    DAKeychain.shared["token"] = token
                }
                if let userId = successResponse.userId {
                    print("DEBUG: userId \(String(describing: userId))")
                    DAKeychain.shared["userId"] = userId
                }
                if let isAdmin = successResponse.isAdmin {
                    DAKeychain.shared["isAdmin"] = String(isAdmin)
                }
                self.initialOnboard = true
                self.loadCurrentState()
            }
        }
    }
}
