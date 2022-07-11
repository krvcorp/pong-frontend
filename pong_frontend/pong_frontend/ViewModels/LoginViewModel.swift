//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation

class LoginViewModel: ObservableObject {
    
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false // this needs to be set to false when app launches. true only to troubleshoot app
    @Published var token: String = ""
    @Published var gmailString: String = ""
    @Published var initialOnboard: Bool = false
    
    func signout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.token = ""
            self.gmailString = ""
            self.password = ""
            self.initialOnboard = true
        }
    }
    
    func verifyEmail(phone: String, email: String) {
        
        API().verifyEmail(phone: phone, email: email) { result in
            switch result {
            case .success(let token):
                self.token = token
                self.isAuthenticated = true
                DAKeychain.shared["token"] = token // Store
//                print("DEBUG loginVM \(self.gmailString)")
            case .failure(let error):
                print("DEBUG: \(error)")
                return
            }

        }
        
    }
}
