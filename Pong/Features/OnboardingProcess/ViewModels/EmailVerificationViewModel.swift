import Foundation
import GoogleSignIn
import MSAL
import SwiftUI


class EmailVerificationViewModel: ObservableObject {

    @Published var loginError: Bool = false
    @Published var loginErrorMessage: String = "error"

    // MARK: Google OAuth2.0
    let signInConfig = GIDConfiguration(clientID: "43678979560-6ah9oj1h0cvvd5is4al3lmkmdmd1tdqd.apps.googleusercontent.com")

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

    // MARK: VerifyEmail, set keychain
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
                        AuthManager.authManager.loadCurrentState()
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
