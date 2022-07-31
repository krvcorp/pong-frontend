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
    @Published var phoneIsProvided: Bool = false
    @Published var phoneIsVerified: Bool = false
    @Published var firstTimeOnboard: Bool = true
    
    func otpStart() {
        otpStartAPI(phone: phone) { result in
            switch result {
                case .success(let newUser):
                    print("DEBUG: PhoneLoginVM newUser is \(newUser)")
                    DispatchQueue.main.async {
                        self.phoneIsProvided = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func otpStartAPI(phone: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        print("DEBUG: API otpStart \(phone)")
        
        // change URL to real login
        guard let url = URL(string: "\(API().rootAuth)" + "otp-start/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = OTPStartRequestBody(phone: phone)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let otpStartResponse = try? JSONDecoder().decode(OTPStartResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            guard let new_user = otpStartResponse.newUser else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(new_user))
            
        }.resume()
    }
    
    func otpVerify(loginVM: LoginViewModel, verificationVM : VerificationViewModel) {
        
        otpVerifyAPI(phone: phone, code: code) { result in
            switch result {
                case .success(let responseDataContent):
                    print("DEBUG: PhoneLoginVM responseDataContent \(responseDataContent)")
                    if let token = responseDataContent.token {
                        DispatchQueue.main.async {
                            // resets phoneLoginVM
                            self.phone = ""
                            self.code = ""
                            self.phoneIsProvided = false
                            self.phoneIsVerified = false
                            
                            DAKeychain.shared["token"] = token // Store
                            if let userId = responseDataContent.userId {
                                DAKeychain.shared["userId"] = userId
                            }

                            // used to force loginVM to update and subsequently the ContentView to update
                            loginVM.forceUpdate.toggle()
                        }
                    } else if responseDataContent.emailUnverified != nil {
                      // If key does not exist, this code will be executed
                        DispatchQueue.main.async {
                            self.phoneIsVerified = true
                        }
                    } else if responseDataContent.codeExpire != nil {
                        DispatchQueue.main.async {
                            verificationVM.showingCodeExpired = true
                        }
                        
                    } else if responseDataContent.codeIncorrect != nil {
                        DispatchQueue.main.async {
                            verificationVM.showingCodeWrong = true
                        }
                    }

                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func otpVerifyAPI(phone: String, code: String, completion: @escaping (Result<OTPVerifyResponseBody, AuthenticationError>) -> Void) {
        // change URL to real login
        guard let url = URL(string: "\(API().rootAuth)" + "otp-verify/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = OTPVerifyRequestBody(phone: phone,code: code)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let otpVerifyResponse = try? decoder.decode(OTPVerifyResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            print("DEBUG: API otpVerifyResponse is \(otpVerifyResponse)")
            
            // token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
            if let responseDataContent = otpVerifyResponse.token {
                print("DEBUG: API Token is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.emailUnverified {
                print("DEBUG: API email_unverified is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.codeExpire {
                print("DEBUG: code_expire is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.codeIncorrect {
                print("DEBUG: code_incorrect is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            print("DEBUG: API \(otpVerifyResponse)")
            completion(.failure(.custom(errorMessage: "Broken")))
            
        }.resume()
    }
}
