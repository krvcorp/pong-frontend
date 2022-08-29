import Foundation
import GoogleSignIn
import Alamofire

class AuthManager: ObservableObject {
    
    static let authManager: AuthManager = AuthManager()
    
    @Published var isSignedIn: Bool = false
    @Published var onboarded: Bool = false
    @Published var userId: String = ""
    @Published var isAdmin: Bool = false
    
    // MARK: LOAD CURRENT STATE
    func loadCurrentState() {
        self.isSignedIn = (DAKeychain.shared["userId"] != nil && DAKeychain.shared["token"] != nil)
        
        if let userId = DAKeychain.shared["userId"] {
            self.userId = userId
        }
        if DAKeychain.shared["isAdmin"] != nil {
            self.isAdmin = true
        }   
        if DAKeychain.shared["onboarded"] != nil {
            self.onboarded = true
        }
    }
    
    // MARK: signout: set keychain nil
    func signout() {
        DispatchQueue.main.async {
            AuthManager.authManager.isSignedIn = false
            AuthManager.authManager.onboarded = false
            GIDSignIn.sharedInstance.disconnect()
            DAKeychain.shared["userId"] = nil
            DAKeychain.shared["token"] = nil
            DAKeychain.shared["isAdmin"] = nil
            DAKeychain.shared["dateJoined"] = nil
            DAKeychain.shared["referralCode"] = nil
            DAKeychain.shared["onboarded"] = nil
        }
    }
    
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
//                        debugPrint(token)
                    }
                    if let userId = successResponse.userId {
                        DAKeychain.shared["userId"] = userId
//                        debugPrint(userId)
                    }
                    if let isAdmin = successResponse.isAdmin {
//                        debugPrint(isAdmin)
                        if isAdmin {
                            DAKeychain.shared["isAdmin"] = String(isAdmin)
                        }
                    }
                    if let dateJoined = successResponse.dateJoined {
//                        debugPrint(dateJoined)
                        DAKeychain.shared["dateJoined"] = String(dateJoined)
                    }
                    if let referralCode = successResponse.referralCode {
//                        debugPrint(referralCode)
                        DAKeychain.shared["referralCode"] = String(referralCode)
                    }
                    if let onboarded = successResponse.onboarded {
                        if onboarded {
                            DAKeychain.shared["onboarded"] = "true"
                        }
                    }
                    self.loadCurrentState()
                }
                if let errorResponse = errorResponse {
                    print("DEBUG: \(errorResponse)")
                }
            }
        }
    }
}
