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
        
        verifyEmailAPI(phone: phone, email: email) { result in
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
    
    func verifyEmailAPI(phone: String, email: String, completion: @escaping (Result <String, AuthenticationError>) -> Void ) {
        
        guard let url = URL(string: "\(API().root)" + "verify-user/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = VerifyEmailRequestBody(phone: phone, email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let verifyEmailResponse = try? JSONDecoder().decode(VerifyEmailResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            print("DEBUG: API otpVerifyResponse is \(verifyEmailResponse)")
            
            // token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
            if let responseDataContent = verifyEmailResponse.token {
                print("DEBUG: API Token is \(responseDataContent)")
                completion(.success(verifyEmailResponse.token!))
                return
            }
            
            
            print("DEBUG: API \(verifyEmailResponse.token!)")
            completion(.failure(.custom(errorMessage: "new_user not returned. Consider code_expire or code_incorrect")))
            
        }.resume()
        
    }
}
