//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation
import GoogleSignIn
import Alamofire

// main actor allows observable object to run in the main queue?
@MainActor class LoginViewModel: ObservableObject {
    @Published var initialOnboard: Bool = false
    @Published var emailVerified: Bool = false
    
    func signout() {
        DispatchQueue.main.async {
            self.initialOnboard = true
            GIDSignIn.sharedInstance.disconnect()
            DAKeychain.shared["userId"] = nil
            DAKeychain.shared["token"] = nil
        }
    }

    func verifyEmail(idToken: String, phoneLoginVM: PhoneLoginViewModel) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let parameterEncoder = JSONParameterEncoder(encoder: encoder)
        
        let parameters: VerifyEmailRequestBody = VerifyEmailRequestBody(idToken: idToken, phone: phoneLoginVM.phone)
        
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request("\(API().root)verify-user/", method: method, parameters: parameters, encoder: parameterEncoder, headers: headers).responseDecodable(of: VerifyEmailResponseBody.self) { response in
            print("DEBUG: loginVM verifyEmail response: \(response)")
            switch response.result {
            case .success(let successResponse):
                print("DEBUG: loginVM verifyEmail successResponse: \(successResponse)")
                DispatchQueue.main.async {
                    if let token = successResponse.token {
                        DAKeychain.shared["token"] = token
                        // this forces loginVM to update and subsequently ContentView to update
                        self.emailVerified = true
                    }
                    if let userId = successResponse.userId {
                        DAKeychain.shared["userId"] = userId
                    }
                    // resets phoneLoginVM and authenticates user
                    phoneLoginVM.phone = ""
                    phoneLoginVM.phoneIsProvided = false
                    phoneLoginVM.phoneIsVerified = false
                    phoneLoginVM.code = ""
                }
            case .failure(let failureResponse):
                print("DEBUG: loginVM verifyEmail failureResponse: \(failureResponse)")
            }
        }
    }
    
    // google related stuff
    let signInConfig = GIDConfiguration(clientID: "983201170682-kttqq1l89i4fpgk15fud1u1hf192fq1q.apps.googleusercontent.com")
    
    func googleSignInButton(phoneLoginVM: PhoneLoginViewModel) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        guard let presentingViewController = window!.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        // send the id token to server
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: presentingViewController) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            user.authentication.do { authentication, error in
                guard error == nil else { return }
                guard let authentication = authentication else { return }

                let idToken = authentication.idToken
                // Send ID token to backend (example below).
                self.verifyEmail(idToken: idToken!, phoneLoginVM: phoneLoginVM)
            }
        }
    }
}

// app delegate was fucking useless? idk what this shit does
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    // google shit
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        var handled: Bool
//
//        handled = GIDSignIn.sharedInstance.handle(url)
//        if handled {
//            return true
//        }
//
//        // Handle other custom URL types.
//
//        // If not handled by this app, return false.
//        return false
//    }
//
//    // more google shit
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//                if error != nil || user == nil {
//                  // Show the app's signed-out state.
//            } else {
//              // Show the app's signed-in state.
//            }
//        }
//        return true
//    }
//}