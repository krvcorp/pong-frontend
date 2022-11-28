import Foundation
import GoogleSignIn
import MSAL
import SwiftUI
import FirebaseMessaging


class EmailVerificationViewModel: ObservableObject {

    @Published var loginError: Bool = false
    @Published var loginErrorMessage: String = "error"


    // MARK: Google OAuth2.0
    let signInConfig = GIDConfiguration(clientID: "43678979560-6ah9oj1h0cvvd5is4al3lmkmdmd1tdqd.apps.googleusercontent.com")

    /// Sign in via Google. Gives the user a popup to sign in with their Google account
    func signinWithGoogle() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        guard let presentingViewController = window!.rootViewController else {
            print("There is no root view controller!")
            return
        }

        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: presentingViewController) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            user.authentication.do { authentication, error in
                guard error == nil else { return }
                guard let authentication = authentication else { return }

                let idToken = authentication.idToken
                self.verifyEmail(idToken: idToken!, loginType: "google")
            }
        }
    }
    
    // MARK: Microsoft MSAL
    /// Sign in via MSAL. Gives the user a popup to sign in with their Microsoft account
    func signInWithMicrosoft() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        guard let presentingViewController = window!.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        do {
            let authority = try MSALB2CAuthority(url: URL(string: "https://login.microsoftonline.com/9f6eb8fa-d85e-4a5d-8df7-6cc10c63ad0c")!)
            let pcaConfig = MSALPublicClientApplicationConfig(clientId: "3f0ac0b7-abf4-4195-a0c3-a855cbe86f79", redirectUri: "msauth.com.krv.pong://auth", authority: authority)
            let application = try MSALPublicClientApplication(configuration: pcaConfig)
            let webViewParameters = MSALWebviewParameters(authPresentationViewController: presentingViewController)
            let interactiveParameters = MSALInteractiveTokenParameters(scopes: ["user.read"], webviewParameters: webViewParameters)
            interactiveParameters.promptType = MSALPromptType.login
            
            application.acquireToken(with: interactiveParameters) { (result, error) in
                
                guard let result = result else {
                    print("error \(String(describing: error?.localizedDescription))")
                    return
                }
                
                if let account = result.account.username {
                    self.verifyEmail(idToken: account, loginType: "microsoft")
                }
            }
        } catch {
            print("\(#function) logging error \(error)")
        }
    }

    // MARK: VerifyEmail
    /// Verifies email and logs in the user if successful. Otherwise it prompts the user that they're unable to sign in
    private func verifyEmail(idToken: String, loginType: String) {
        let parameters = VerifyEmailModel.Request(idToken: idToken, loginType: loginType)
        
        NetworkManager.networkManager.request(route: "login/", method: .post, body: parameters, successType: VerifyEmailModel.Response.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                withAnimation {
                    if let successResponse = successResponse {
                        if let token = successResponse.token {
                            DAKeychain.shared["token"] = token
                        }
                        if let userId = successResponse.userId {
                            DAKeychain.shared["userId"] = userId
                        }
                        if let isAdmin = successResponse.isAdmin {
                            if isAdmin {
                                DAKeychain.shared["isAdmin"] = String(isAdmin)
                            }
                        }
                        if let dateJoined = successResponse.dateJoined {
                            DAKeychain.shared["dateJoined"] = String(dateJoined)
                        }
                        if let referralCode = successResponse.referralCode {
                            DAKeychain.shared["referralCode"] = String(referralCode)
                        }
                        if let onboarded = successResponse.onboarded {
                            if onboarded {
                                DAKeychain.shared["onboarded"] = "true"
                            }
                        }
                        if let referred = successResponse.referred {
                            if referred {
                                DAKeychain.shared["referred"] = "true"
                            }
                        }
                        if successResponse.postBubble {
                            DAKeychain.shared["postBubble"] = "true"
                        } else {
                            DAKeychain.shared["postBubble"] = "false"
                        }
                        
                        
                        // store FCM token and send it
                        Messaging.messaging().token { token, error in
                            if let token = token {
                                DAKeychain.shared["fcm"] = token
                                
                                NotificationsManager().sendFCM()
                            }
                        }
                        
                        // LOAD CURRENT STATE
                        AuthManager.authManager.loadCurrentState()
                        
                        // LOAD STARTUP STATE
                        DataManager.shared.loadStartupState()
                        
                    }
                    
                    if let errorResponse = errorResponse {
                        self.loginErrorMessage = errorResponse.error
                        self.loginError = true
                    }
                }
            }
        }
    }
}
