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
}
