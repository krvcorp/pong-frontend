//
//  PhoneLoginModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/7/22.
//

import Foundation

struct OTPStartRequestBody: Codable {
    let phone: String
}

struct OTPStartResponseBody: Codable {
    let newUser: Bool?
    let phone: String?
}

struct OTPVerifyRequestBody: Codable {
    let phone: String
    let code: String
}

// token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
struct OTPVerifyResponseBody: Codable {
    let token: String?
    let emailUnverified: Bool?
    let codeExpire: Bool?
    let codeIncorrect: Bool?
}

class PhoneLoginViewModel: ObservableObject {
    @Published var phone: String = ""
    @Published var code: String = ""
    @Published var phoneIsProvided: Bool = false // this needs to be set to false when app launches. true only to troubleshoot app
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
        guard let url = URL(string: "\(API().root)" + "otp-start/") else {
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
    
    func otpVerify(loginVM: LoginViewModel, bannerVM : BannerViewModel) {
        
        otpVerifyAPI(phone: phone, code: code) { result in
            switch result {
                case .success(let responseDataContent):
                    print("DEBUG: PhoneLoginVM responseDataContent \(responseDataContent)")

                    // if token then go to main view
                    // if email_unverified is true then go to GoogleSignInView
                    // if code_expire is true then banner activate that code_expired
                    // if code_incorrect is true then banner active that code_incorrect
                    if let token = responseDataContent.token {
                       // If key exist, this code will be executed
                        DispatchQueue.main.async {
                            DAKeychain.shared["token"] = token // Store
                            self.phone = ""
                            self.phoneIsVerified = false
                            self.code = ""
                            loginVM.isAuthenticated = true
                        }
                    } else if responseDataContent.emailUnverified != nil {
                      // If key does not exist, this code will be executed
                        DispatchQueue.main.async {
                            self.phoneIsVerified = true
                        }
                    } else if responseDataContent.codeExpire != nil {
                        bannerVM.bannerData = BannerModifier.BannerData(title: "Code Expired", detail: "Your code expired.", type: .Error)
                        bannerVM.showBanner = true
                        
                    } else if responseDataContent.codeIncorrect != nil {
                        bannerVM.bannerData = BannerModifier.BannerData(title: "Code Incorrect", detail: "Your code is incorrect.", type: .Error)
                        bannerVM.showBanner = true
                    }

                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func otpVerifyAPI(phone: String, code: String, completion: @escaping (Result<OTPVerifyResponseBody, AuthenticationError>) -> Void) {
        // change URL to real login
        guard let url = URL(string: "\(API().root)" + "otp-verify/") else {
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
