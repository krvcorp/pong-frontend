import Foundation
import GoogleSignIn


class EmailVerificationViewModel: ObservableObject {

    @Published var loginError: Bool = false
    @Published var loginErrorMessage: String = "error"

    // MARK: Google OAuth2.0
    let signInConfig = GIDConfiguration(clientID: "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")

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
                self.verifyEmail(idToken: idToken!)
            }
        }
    }

    // MARK: VerifyEmail, set keychain
    private func verifyEmail(idToken: String) {
        let parameters = VerifyEmailModel.Request(idToken: idToken)
        
        NetworkManager.networkManager.request(route: "login/", method: .post, body: parameters, successType: VerifyEmailModel.Response.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
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
