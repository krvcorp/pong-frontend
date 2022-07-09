//
//  PhoneLoginModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/7/22.
//

import Foundation

class PhoneLoginViewModel: ObservableObject {
    
    @Published var phone: String = ""
    @Published var code: String = ""
    @Published var phoneIsProvided: Bool = false // this needs to be set to false when app launches. true only to troubleshoot app
    @Published var phoneIsVerified: Bool = false
    @Published var token: String = ""
    
    func otpStart() {
        
//        let defaults = UserDefaults.standard
        
        API().otpStart(phone: phone) { result in
            switch result {
                case .success(let new_user):
                    print("DEBUG: PhoneLoginVM new_user is \(new_user)")
//                    defaults.setValue(token, forKey: "jsonwebtoken")
                    DispatchQueue.main.async {
                        self.phoneIsProvided = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func otpVerify(loginVM: LoginViewModel) {
        
        let defaults = UserDefaults.standard
        
        API().otpVerify(phone: phone, code: code) { result in
            switch result {
                case .success(let responseDataContent):
                    print("DEBUG: PhoneLoginVM responseDataContent \(responseDataContent)")

                    // if token then go to main view
                    // if email_unverified is true then go to GoogleSignInView
                    if let token = responseDataContent.token {
                       // If key exist, this code will be executed
                        defaults.setValue(token, forKey: "jsonwebtoken")
                        loginVM.isAuthenticated = true
                    } else {
                      // If key does not exist, this code will be executed
                        DispatchQueue.main.async {
                            self.phoneIsVerified = true
                        }
                    }

                
                

                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}
