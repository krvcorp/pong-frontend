import Foundation
import GoogleSignIn
import Alamofire
import SwiftUI

class AuthManager: ObservableObject {
    
    static let authManager: AuthManager = AuthManager()
    
    @Published var isSignedIn: Bool = false
    @Published var onboarded: Bool = false
    @Published var userId: String = ""
    @Published var isAdmin: Bool = false
    @Published var signedOutAlert : Bool = false
    
    // MARK: LOAD CURRENT STATE
    func loadCurrentState() {
        withAnimation {
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
    }
    
    // MARK: signout: set keychain nil
    func signout() {
        DispatchQueue.main.async {
            withAnimation {
                AuthManager.authManager.isSignedIn = false
                AuthManager.authManager.onboarded = false
                GIDSignIn.sharedInstance.disconnect()
                DAKeychain.shared["userId"] = nil
                DAKeychain.shared["token"] = nil
                DAKeychain.shared["isAdmin"] = nil
                DAKeychain.shared["dateJoined"] = nil
                DAKeychain.shared["referralCode"] = nil
                DAKeychain.shared["onboarded"] = nil
                self.signedOutAlert = true
            }
        }
    }
}
