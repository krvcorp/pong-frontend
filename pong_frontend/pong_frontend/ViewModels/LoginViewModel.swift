//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation

@MainActor class LoginViewModel: ObservableObject {
    
    @Published var email_or_username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false // this needs to be set to false when app launches. true only to troubleshoot app
    @Published var token: String = ""
    @Published var gmailString: String = ""
    
    func login() {
        
        let defaults = UserDefaults.standard
        
        API().login(email_or_username: email_or_username, password: password) { result in
            switch result {
                case .success(let token):
                    print("DEBUG: \(result)")
                    defaults.setValue(token, forKey: "jsonwebtoken")
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func signout() {
           
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "jsonwebtoken")
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
    
    func verifyEmail(phone: String, email: String) {
        
        API().verifyEmail(phone: phone, email: email) { result in
            switch result {
            case .success(let token):
                self.token = token
                self.isAuthenticated = true
                let defaults = UserDefaults.standard
                defaults.setValue(token, forKey: "jsonwebtoken")
                print("DEBUG loginVM \(self.gmailString)")
            case .failure(let error):
                print("DEBUG: \(error)")
                return
            }

        }
        
    }
}
