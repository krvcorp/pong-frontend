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
    /// Determines if the user is signed in by checking the keychain for a userId and a token.
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
    
    struct Registration {
        struct Request: Encodable { let fcm_token: String }
        struct Success: Decodable {}
    }
    
    // MARK: Signout
    /// Signs out the user. It will reset UserDefaults and remove all entries stored in the keychain.
    func signout(force : Bool) {
        if force {
            DispatchQueue.main.async {
                withAnimation {
                    self.resetDefaults()
                    AuthManager.authManager.isSignedIn = false
                    AuthManager.authManager.onboarded = false
                    DAKeychain.shared["userId"] = nil
                    DAKeychain.shared["token"] = nil
                    DAKeychain.shared["isAdmin"] = nil
                    DAKeychain.shared["dateJoined"] = nil
                    DAKeychain.shared["referralCode"] = nil
                    DAKeychain.shared["onboarded"] = nil
                    DAKeychain.shared["referred"] = nil
                    DAKeychain.shared["postBubble"] = nil
                    self.signedOutAlert = true

                    // reset datamanager
                    DataManager.shared.reset()
                    
                    MainTabViewModel.shared.itemSelected = 1
                }
            }
        } else {
            NotificationsManager().removeFCMToken() {success in
                DispatchQueue.main.async {
                    withAnimation {
                        self.resetDefaults()
                        AuthManager.authManager.isSignedIn = false
                        AuthManager.authManager.onboarded = false
                        DAKeychain.shared["userId"] = nil
                        DAKeychain.shared["token"] = nil
                        DAKeychain.shared["isAdmin"] = nil
                        DAKeychain.shared["dateJoined"] = nil
                        DAKeychain.shared["referralCode"] = nil
                        DAKeychain.shared["onboarded"] = nil
                        DAKeychain.shared["referred"] = nil
                        self.signedOutAlert = true

                        // reset datamanager
                        DataManager.shared.reset()
                        
                        MainTabViewModel.shared.itemSelected = 1
                    }
                }
            }
        }
    }
    
    // MARK: ResetDefaults
    /// Helper function to remove all entries in UserDefaults
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
